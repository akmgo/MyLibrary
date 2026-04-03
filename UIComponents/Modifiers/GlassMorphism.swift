import AppKit
import SwiftUI

// MARK: - 1. 动态流体光影引擎 (满屏覆盖版)

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

// MARK: - 2. 玻璃材质与控件修饰引擎

extension View {
    /// 顶级液态玻璃底座 (用于导航栏等)
    func liquidGlass(cornerRadius: CGFloat = 16, isDark: Bool = false) -> some View {
        self.background(
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.thickMaterial)
                    .opacity(0.9)
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(isDark ? Color.black.opacity(0.4) : Color.white.opacity(0.6))
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(isDark ? Color.white.opacity(0.1) : Color.white.opacity(0.6), lineWidth: 1)
        )
    }
    
    /// 弹窗专属液态玻璃材质
    func liquidSheet(isDark: Bool) -> some View {
        self.background(
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous).fill(.thinMaterial).opacity(0.8)
                RoundedRectangle(cornerRadius: 24, style: .continuous).fill(isDark ? Color.black.opacity(0.1) : Color.white.opacity(0.1))
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(LinearGradient(colors: [.white.opacity(isDark ? 0.3 : 0.9), .white.opacity(isDark ? 0.05 : 0.3), .clear, isDark ? .black.opacity(0.6) : .black.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
        )
    }

    /// 按钮专属液态玻璃
    func liquidButtonGlass(cornerRadius: CGFloat = 12, isDark: Bool = false, tintColor: Color? = nil) -> some View {
        self.background(
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous).fill(.thinMaterial).opacity(0.9)
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous).fill(tintColor ?? Color.clear)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(LinearGradient(colors: [.white.opacity(isDark ? 0.3 : 0.6), .white.opacity(0.1), .white.opacity(isDark ? 0.05 : 0.2)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.2)
        )
    }
    
    /// ✨ 新增：圆形液态玻璃 (专用于左右切换、操作等圆形悬浮按钮)
    func liquidCircleGlass(isHovered: Bool = false, isDark: Bool = false) -> some View {
        self.background(
            ZStack {
                Circle().fill(.ultraThinMaterial)
                Circle().fill(isDark ? Color.white.opacity(isHovered ? 0.15 : 0.05) : Color.white.opacity(isHovered ? 0.6 : 0.3))
            }
        )
        .clipShape(Circle())
        .overlay(
            Circle().stroke(isDark ? Color.white.opacity(0.15) : Color.white.opacity(0.8), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(isDark ? (isHovered ? 0.3 : 0) : (isHovered ? 0.12 : 0.05)), radius: isHovered ? 10 : 4, y: isHovered ? 5 : 2)
        .scaleEffect(isHovered ? 1.05 : 1.0)
    }
    
    /// 液态输入框 (真实内凹感)
    func liquidInput(isDark: Bool, cornerRadius: CGFloat = 12) -> some View {
        self.padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous).fill(isDark ? Color.black.opacity(0.4) : Color.black.opacity(0.06)))
            .overlay(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous).stroke(isDark ? Color.white.opacity(0.1) : Color.black.opacity(0.08), lineWidth: 1))
    }

    /// 外部大区块底座样式 (Dashboard 整体面板等)
    func outerGlassBlockStyle() -> some View {
        self.background(
            ZStack {
                RoundedRectangle(cornerRadius: 40, style: .continuous).fill(Color(NSColor.windowBackgroundColor).opacity(0.4))
                RoundedRectangle(cornerRadius: 40, style: .continuous).fill(Color.clear).background(.ultraThinMaterial)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 40, style: .continuous).stroke(Color.primary.opacity(0.05), lineWidth: 1))
        .shadow(color: Color.black.opacity(0.1), radius: 35, x: 0, y: 25)
    }

    /// 内部悬浮卡片样式 (Dashboard 内部子卡片)
    func innerGlassCardStyle(isHovered: Bool = false) -> some View {
        self.background(
            ZStack {
                RoundedRectangle(cornerRadius: 32, style: .continuous).fill(Color(NSColor.controlBackgroundColor).opacity(0.4))
                RoundedRectangle(cornerRadius: 32, style: .continuous).fill(Color.clear).background(.regularMaterial)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 32, style: .continuous).stroke(Color.primary.opacity(0.05), lineWidth: 1))
        .shadow(color: Color.black.opacity(isHovered ? 0.15 : 0.05), radius: isHovered ? 25 : 15, x: 0, y: isHovered ? 18 : 8)
        .offset(y: isHovered ? -6 : 0)
    }
}

// MARK: - 3. 鼠标交互与 3D 特效

extension View {
    /// 鼠标悬浮指针 (纯血 Mac 版)
    func pointingHand() -> some View {
        self.onHover { isHovered in if isHovered { NSCursor.pointingHand.push() } else { NSCursor.pop() } }
    }
    
    /// 3D 悬浮倾斜特效
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

// MARK: - 4. 统计卡片背景纹理

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
