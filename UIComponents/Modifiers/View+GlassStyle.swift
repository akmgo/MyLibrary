// Utils/View+GlassStyle.swift
import SwiftUI

// MARK: - 样式修饰符
struct OuterGlassBlockModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        let isDark = colorScheme == .dark
        
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 40, style: .continuous)
                        .fill(isDark ? Color.twSlate900 : Color.white.opacity(0.6))
                    RoundedRectangle(cornerRadius: 40, style: .continuous)
                        .fill(Color.clear).background(.ultraThinMaterial)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 40, style: .continuous)
                    .stroke(isDark ? Color.twSlate800.opacity(0.5) : Color.white.opacity(0.6), lineWidth: 1)
            )
            // ✨ 强化外层悬浮：加深透明度，增大向下(Y)的偏移量和扩散半径
            .shadow(
                color: Color.black.opacity(isDark ? 0.4 : 0.18), // 深色 0.4，浅色 0.18 (变浓)
                radius: 35, // 扩散范围变大
                x: 0,
                y: 25  // 明显向下偏移，制造高度差
            )
    }
}

struct InnerGlassCardModifier: ViewModifier {
    var isHovered: Bool
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        let isDark = colorScheme == .dark
        
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(isDark ? Color.twSlate900.opacity(0.4) : Color.white.opacity(0.4))
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(Color.clear).background(.regularMaterial)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(isDark ? Color.white.opacity(0.1) : Color.white.opacity(0.6), lineWidth: 1)
            )
            // ✨ 强化内层悬浮：增加阴影的存在感和动态交互的高度落差
            .shadow(
                // 悬浮时变浓，静止时也比以前浓
                color: Color.black.opacity(isDark ? (isHovered ? 0.4 : 0.25) : (isHovered ? 0.25 : 0.12)),
                radius: isHovered ? 25 : 15, // 交互时大幅度散开
                x: 0,
                y: isHovered ? 18 : 8 // 明显向底部坠落的阴影
            )
            // 配合阴影，悬浮时的物理位移也稍微加大一点，感觉更轻盈
            .offset(y: isHovered ? -6 : 0)
    }
}

// MARK: - 鼠标跟随 3D 偏转特效
struct TiltCardModifier: ViewModifier {
    @State private var rotationX: CGFloat = 0
    @State private var rotationY: CGFloat = 0
    let maxTilt: CGFloat = 5
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(.degrees(rotationX), axis: (x: 1, y: 0, z: 0), perspective: 1.0)
            .rotation3DEffect(.degrees(rotationY), axis: (x: 0, y: 1, z: 0), perspective: 1.0)
            // ✨ 核心修复：把贪婪的 GeometryReader 关进 overlay 里
            // 这样它就会严丝合缝地贴在你的封面上，绝对不会再撑爆布局！
            .overlay(
                GeometryReader { geo in
                    Color.clear
                        .contentShape(Rectangle())
                        .onContinuousHover { phase in
                            switch phase {
                            case .active(let location):
                                let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                                let tiltX = ((location.y - center.y) / center.y) * -maxTilt
                                let tiltY = ((location.x - center.x) / center.x) * maxTilt
                                
                                withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.7)) {
                                    rotationX = tiltX
                                    rotationY = tiltY
                                }
                            case .ended:
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                                    rotationX = 0
                                    rotationY = 0
                                }
                            }
                        }
                }
            )
    }
}


extension View {
    func outerGlassBlockStyle() -> some View { self.modifier(OuterGlassBlockModifier()) }
    func innerGlassCardStyle(isHovered: Bool = false) -> some View { self.modifier(InnerGlassCardModifier(isHovered: isHovered)) }
    func tiltCardEffect() -> some View { self.modifier(TiltCardModifier()) }
}

// MARK: - 网页版右侧专属背景纹理
struct GridLineShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        for x in stride(from: 0, through: rect.width, by: 24) { path.move(to: CGPoint(x: x, y: 0)); path.addLine(to: CGPoint(x: x, y: rect.height)) }
        for y in stride(from: 0, through: rect.height, by: 24) { path.move(to: CGPoint(x: 0, y: y)); path.addLine(to: CGPoint(x: rect.width, y: y)) }
        return path
    }
}

struct GridDotShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        for x in stride(from: 0, through: rect.width, by: 16) {
            for y in stride(from: 0, through: rect.height, by: 16) { path.addEllipse(in: CGRect(x: x, y: y, width: 2, height: 2)) }
        }
        return path
    }
}
