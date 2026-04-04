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

@available(macOS 15.0, iOS 18.0, *)
struct FluidBackgroundView: View {
    var isDark: Bool

    var body: some View {
        // 闭包里只保留最简单的调用，绝不给编译器增加负担
        TimelineView(.animation) { timeline in
            self.animatedMesh(date: timeline.date)
        }
        .allowsHitTesting(false)
    }

    /// ✨ 核心修复：把渲染逻辑完全抽离到一个明确返回 `some View` 的独立函数中
    private func animatedMesh(date: Date) -> some View {
        // 1. 计算时间与坐标
        let time = Float(date.timeIntervalSinceReferenceDate) * 0.2
        let xOffset = 0.2 * sin(time)
        let yOffset = 0.2 * cos(time * 0.8)
        let centerPoint = SIMD2<Float>(0.5 + xOffset, 0.5 + yOffset)

        // 2. 准备颜色矩阵
        let darkColors: [Color] = [
            Color.twSlate950, Color.twIndigo900, Color.twSlate950,
            Color.twPurple900, Color.twSky900, Color.twFuchsia900,
            Color.twSlate950, Color.twIndigo950, Color.twSlate950
        ]

        let lightColors: [Color] = [
            Color.twSlate50, Color.twIndigo200, Color.twSlate50,
            Color.twPurple200, Color.twSky300, Color.twFuchsia300,
            Color.twSlate50, Color.twIndigo200, Color.twSlate50
        ]

        // 3. 返回网格渐变
        return MeshGradient(
            width: 3,
            height: 3,
            points: [
                .init(0, 0), .init(0.5, 0), .init(1, 0),
                .init(0, 0.5), centerPoint, .init(1, 0.5),
                .init(0, 1), .init(0.5, 1), .init(1, 1)
            ],
            colors: self.isDark ? darkColors : lightColors
        )
        .ignoresSafeArea()
        .opacity(self.isDark ? 0.35 : 0.3)
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

    /// ✨ 外部大区块底座样式 (四周发散阴影 + 高亮玻璃切边)
    func outerGlassBlockStyle(radius: CGFloat = AppleRadius.hero) -> some View {
        self
            .background(Color(NSColor.windowBackgroundColor).opacity(0.4))
            .background(.ultraThinMaterial)
            .appleClip(radius: radius)
            // 🚀 亮度提升：加入 0.2 的白色边框，让玻璃罩边缘有物理切割的反光感
            .appleBorder(Color.white.opacity(0.5), radius: radius, lineWidth: 1)
            // 🚀 四周均匀阴影：将 y 设为 0，让阴影往上下左右 4 个方向均匀发散
            .shadow(color: Color.black.opacity(0.3), radius: 45, x: 0, y: 0)
    }

    /// ✨ 内部悬浮卡片样式 (发散发光态 + 悬浮高亮)
    func innerGlassCardStyle(outerRadius: CGFloat = AppleRadius.hero, paddingToOuter: CGFloat = 8, isHovered: Bool = false) -> some View {
        let radius = AppleRadius.nested(outer: outerRadius, padding: paddingToOuter)

        return self
            .background(Color(NSColor.controlBackgroundColor).opacity(0.4))
            .background(.regularMaterial)
            .appleClip(radius: radius)
            // 🚀 亮度提升交互：
            // - 平时：淡淡的 0.15 白色勾边
            // - 悬浮时：边框瞬间亮起，达到 0.6 的高亮白色，仿佛内部有光亮起
            .appleBorder(isHovered ? Color.white.opacity(0.6) : Color.white.opacity(0.15), radius: radius, lineWidth: 1)
            // 🚀 四周均匀阴影：
            // - 将 y 轴无情归 0。
            // - 悬浮时不仅阴影变大 (45)，而且颜色变深，仿佛整个卡片挡住了一束巨大的强光。
            .shadow(color: Color.black.opacity(isHovered ? 0.3 : 0.25),
                    radius: isHovered ? 45 : 20,
                    x: 0,
                    y: 0) // <-- 核心：y = 0 产生四周包围的均匀弥散感！

            .offset(y: isHovered ? -8 : 0)
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isHovered)
    }

    /// ✨ 主页专属静态悬浮卡片 (仅保留基座质感，移除整体悬浮动态)
    func homeStaticGlassCardStyle(outerRadius: CGFloat = AppleRadius.hero, paddingToOuter: CGFloat = 8) -> some View {
        let radius = AppleRadius.nested(outer: outerRadius, padding: paddingToOuter)

        return self
            .background(Color(NSColor.controlBackgroundColor).opacity(0.4))
            .background(.regularMaterial)
            .appleClip(radius: radius)
            // 保持静止态的微弱高光边框
            .appleBorder(Color.white.opacity(0.15), radius: radius, lineWidth: 1)
            // 保持静止态四周包围的均匀弥散感 (y = 0)
            .shadow(color: Color.black.opacity(0.25), radius: 20, x: 0, y: 0)
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
    @State private var isHovered: Bool = false // ✨ 悬浮状态跟踪
    let maxTilt: CGFloat = 5

    func body(content: Content) -> some View {
        content
            // 🚀 1. 3D 倾斜
            .rotation3DEffect(.degrees(self.rotationX), axis: (x: 1, y: 0, z: 0), perspective: 1.0)
            .rotation3DEffect(.degrees(self.rotationY), axis: (x: 0, y: 1, z: 0), perspective: 1.0)
            // 🚀 2. 靠近镜头感与阴影 (只跟随 isHovered 变化)
            .scaleEffect(self.isHovered ? 1.02 : 1.0)
            .shadow(color: Color.black.opacity(self.isHovered ? 0.2 : 0), radius: self.isHovered ? 30 : 0, x: 0, y: self.isHovered ? 15 : 0)
            // ✨ 优化点 1：把悬浮状态独立出来！确保进出时只触发一次，动画绝不被打断
            .onHover { hovering in
                // 这里的动画专门为放大和阴影服务，更加舒缓
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    self.isHovered = hovering
                }
            }
            .overlay(
                GeometryReader { geo in
                    Color.clear.contentShape(Rectangle()).onContinuousHover { phase in
                        switch phase {
                        case .active(let location):
                            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                            // ✨ 优化点 2：这里的动画专门为倾斜服务，更加灵敏
                            withAnimation(.interactiveSpring(response: 0.2, dampingFraction: 0.6)) {
                                self.rotationX = ((location.y - center.y) / center.y) * -self.maxTilt
                                self.rotationY = ((location.x - center.x) / center.x) * self.maxTilt
                            }
                        case .ended:
                            // ✨ 鼠标离开时：回正旋转角度
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                self.rotationX = 0
                                self.rotationY = 0
                            }
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
