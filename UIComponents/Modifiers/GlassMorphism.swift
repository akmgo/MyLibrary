import AppKit
import SwiftUI

// MARK: - ✨ 1. 苹果同心圆角设计系统 (Apple Curve Design System)

public enum AppleRadius {
    /// 原生系统级小圆角 (常用于小按钮、输入框) -> 12
    public static let small: CGFloat = 12
    
    /// 原生窗口级标准圆角 (常用于导航栏、独立小卡片) -> 16
    public static let regular: CGFloat = 16
    
    /// 现代卡片级大圆角 (常用于 Dashboard 中型模块) -> 24
    public static let card: CGFloat = 24
    
    /// 弹窗与画廊级超大圆角 (常用于 Sheet 弹窗、主视觉模块) -> 32
    public static let modal: CGFloat = 32
    
    /// 极限包裹级英雄圆角 (如 Dashboard 外部大底座) -> 40
    public static let hero: CGFloat = 40
    
    /// ✨ 核心魔法：同心圆角计算器
    public static func nested(outer: CGFloat, padding: CGFloat) -> CGFloat {
        return max(outer - padding, 0)
    }
}

public extension View {
    func appleClip(radius: CGFloat = AppleRadius.card) -> some View {
        self.clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
    func appleBorder(_ color: Color, radius: CGFloat = AppleRadius.card, lineWidth: CGFloat = 1) -> some View {
        self.overlay(RoundedRectangle(cornerRadius: radius, style: .continuous).stroke(color, lineWidth: lineWidth))
    }
    func appleBackground(_ color: Color, radius: CGFloat = AppleRadius.card) -> some View {
        self.background(RoundedRectangle(cornerRadius: radius, style: .continuous).fill(color))
    }
}


// MARK: - 2. 动态流体光影引擎 (满屏覆盖版)

struct FluidBackgroundView: View {
    var isDark: Bool
    @State private var move = false

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                (self.isDark ? Color.twSlate950 : Color.twSlate50).ignoresSafeArea()

                Circle()
                    .fill(LinearGradient(colors: [.twIndigo400, .twPurple500], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .opacity(self.isDark ? 0.35 : 0.25)
                    .frame(width: w * 1.2, height: w * 1.2)
                    .blur(radius: 150)
                    .offset(x: self.move ? -w * 0.1 : w * 0.3, y: self.move ? -h * 0.2 : h * 0.2)

                Circle()
                    .fill(LinearGradient(colors: [.twSky300, .twIndigo300], startPoint: .leading, endPoint: .trailing))
                    .opacity(self.isDark ? 0.3 : 0.2)
                    .frame(width: w * 1.5, height: w * 1.5)
                    .blur(radius: 180)
                    .offset(x: self.move ? w * 0.4 : -w * 0.2, y: self.move ? h * 0.3 : -h * 0.1)

                Circle()
                    .fill(Color.twFuchsia400)
                    .opacity(self.isDark ? 0.2 : 0.15)
                    .frame(width: w * 1.0, height: w * 1.0)
                    .blur(radius: 150)
                    .offset(x: self.move ? w * 0.1 : w * 0.4, y: self.move ? -h * 0.1 : h * 0.5)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) { self.move.toggle() }
        }
    }
}

// MARK: - 3. 玻璃材质与控件修饰引擎

extension View {
    /// 顶级液态玻璃底座 (已接入 AppleRadius.regular: 16)
    func liquidGlass(radius: CGFloat = AppleRadius.regular, isDark: Bool = false) -> some View {
        self.background(
            ZStack {
                RoundedRectangle(cornerRadius: radius, style: .continuous).fill(.thickMaterial).opacity(0.9)
                RoundedRectangle(cornerRadius: radius, style: .continuous).fill(isDark ? Color.black.opacity(0.4) : Color.white.opacity(0.6))
            }
        )
        .appleClip(radius: radius)
        .appleBorder(isDark ? Color.white.opacity(0.1) : Color.white.opacity(0.6), radius: radius)
    }

    /// 弹窗专属液态玻璃材质 (已接入 AppleRadius.card: 24)
    func liquidSheet(radius: CGFloat = AppleRadius.card, isDark: Bool) -> some View {
        self.background(
            ZStack {
                RoundedRectangle(cornerRadius: radius, style: .continuous).fill(.thinMaterial).opacity(0.8)
                RoundedRectangle(cornerRadius: radius, style: .continuous).fill(isDark ? Color.black.opacity(0.1) : Color.white.opacity(0.1))
            }
        )
        .appleClip(radius: radius)
        .overlay(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .stroke(LinearGradient(colors: [.white.opacity(isDark ? 0.3 : 0.9), .white.opacity(isDark ? 0.05 : 0.3), .clear, isDark ? .black.opacity(0.6) : .black.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
        )
    }

    /// 按钮专属液态玻璃 (已接入 AppleRadius.small: 12)
    func liquidButtonGlass(radius: CGFloat = AppleRadius.small, isDark: Bool = false, tintColor: Color? = nil) -> some View {
        self.background(
            ZStack {
                RoundedRectangle(cornerRadius: radius, style: .continuous).fill(.thinMaterial).opacity(0.9)
                RoundedRectangle(cornerRadius: radius, style: .continuous).fill(tintColor ?? Color.clear)
            }
        )
        .appleClip(radius: radius)
        .overlay(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .stroke(LinearGradient(colors: [.white.opacity(isDark ? 0.3 : 0.6), .white.opacity(0.1), .white.opacity(isDark ? 0.05 : 0.2)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.2)
        )
    }

    /// 圆形液态玻璃 (无需接 Radius，保持正圆)
    func liquidCircleGlass(isHovered: Bool = false, isDark: Bool = false) -> some View {
        self.background(
            ZStack {
                Circle().fill(.ultraThinMaterial)
                Circle().fill(isDark ? Color.white.opacity(isHovered ? 0.15 : 0.05) : Color.white.opacity(isHovered ? 0.6 : 0.3))
            }
        )
        .clipShape(Circle())
        .overlay(Circle().stroke(isDark ? Color.white.opacity(0.15) : Color.white.opacity(0.8), lineWidth: 1))
        .shadow(color: Color.black.opacity(isDark ? (isHovered ? 0.3 : 0) : (isHovered ? 0.12 : 0.05)), radius: isHovered ? 10 : 4, y: isHovered ? 5 : 2)
        .scaleEffect(isHovered ? 1.05 : 1.0)
    }

    /// 液态输入框 (真实内凹感，已接入 AppleRadius.small: 12)
    func liquidInput(radius: CGFloat = AppleRadius.small, isDark: Bool) -> some View {
        self.padding(.horizontal, 16)
            .padding(.vertical, 12)
            .appleBackground(isDark ? Color.black.opacity(0.4) : Color.black.opacity(0.06), radius: radius)
            .appleBorder(isDark ? Color.white.opacity(0.1) : Color.black.opacity(0.08), radius: radius)
    }

    /// ✨ 外部大区块底座样式 (已接入防闪烁链式渲染 + AppleRadius.hero: 40)
    func outerGlassBlockStyle(radius: CGFloat = AppleRadius.hero) -> some View {
        self
            .background(Color(NSColor.windowBackgroundColor).opacity(0.4))
            .background(.ultraThinMaterial)
            .appleClip(radius: radius)
            .appleBorder(Color.primary.opacity(0.05), radius: radius)
            .shadow(color: Color.black.opacity(0.1), radius: 35, x: 0, y: 25)
    }

    /// ✨ 内部悬浮卡片样式 (结合同心圆角黄金公式计算，已接入防闪烁链式渲染)
    func innerGlassCardStyle(outerRadius: CGFloat = AppleRadius.hero, paddingToOuter: CGFloat = 8, isHovered: Bool = false) -> some View {
        let radius = AppleRadius.nested(outer: outerRadius, padding: paddingToOuter)
        
        return self
            .background(Color(NSColor.controlBackgroundColor).opacity(0.4))
            .background(.regularMaterial)
            .appleClip(radius: radius)
            .appleBorder(Color.primary.opacity(0.05), radius: radius)
            .shadow(color: Color.black.opacity(isHovered ? 0.15 : 0.05), radius: isHovered ? 25 : 15, x: 0, y: isHovered ? 18 : 8)
            .offset(y: isHovered ? -6 : 0)
    }
}

// MARK: - 4. 鼠标交互与 3D 特效

extension View {
    func pointingHand() -> some View {
        self.onHover { isHovered in if isHovered { NSCursor.pointingHand.push() } else { NSCursor.pop() } }
    }

    func tiltCardEffect() -> some View {
        self.modifier(TiltCardModifier())
    }
}

private struct TiltCardModifier: ViewModifier {
    @State private var rotationX: CGFloat = 0
    @State private var rotationY: CGFloat = 0
    let maxTilt: CGFloat = 5

    func body(content: Content) -> some View {
        content
            .rotation3DEffect(.degrees(self.rotationX), axis: (x: 1, y: 0, z: 0), perspective: 1.0)
            .rotation3DEffect(.degrees(self.rotationY), axis: (x: 0, y: 1, z: 0), perspective: 1.0)
            .overlay(
                GeometryReader { geo in
                    Color.clear.contentShape(Rectangle()).onContinuousHover { phase in
                        switch phase {
                        case .active(let location):
                            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                            withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.7)) {
                                self.rotationX = ((location.y - center.y) / center.y) * -self.maxTilt
                                self.rotationY = ((location.x - center.x) / center.x) * self.maxTilt
                            }
                        case .ended:
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) { self.rotationX = 0; self.rotationY = 0 }
                        }
                    }
                }
            )
    }
}

// MARK: - 5. 统计卡片背景纹理

struct GridLineShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        for x in stride(from: 0, through: rect.width, by: 24) {
            path.move(to: CGPoint(x: x, y: 0)); path.addLine(to: CGPoint(x: x, y: rect.height))
        }
        for y in stride(from: 0, through: rect.height, by: 24) {
            path.move(to: CGPoint(x: 0, y: y)); path.addLine(to: CGPoint(x: rect.width, y: y))
        }
        return path
    }
}

struct GridDotShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        for x in stride(from: 0, through: rect.width, by: 16) {
            for y in stride(from: 0, through: rect.height, by: 16) {
                path.addEllipse(in: CGRect(x: x, y: y, width: 2, height: 2))
            }
        }
        return path
    }
}
