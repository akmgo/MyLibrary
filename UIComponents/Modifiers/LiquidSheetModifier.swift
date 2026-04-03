import SwiftUI
// MARK: - 🔮 核心液态引擎升级

// ✨ 1. 专门为弹窗打造的液态修饰器 (彻底解决黑白反转)
// ✨ 弹窗专属液态修饰器 (修复透光率 Bug 版)
struct LiquidSheetModifier: ViewModifier {
    var isDark: Bool
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // ==========================================
                    // 🎛️ 旋钮 1 & 2：控制【模糊度】与【底层轮廓透射】
                    // ==========================================
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        // 旋钮 1：材质类型（决定模糊半径）
                        // 最透：.ultraThinMaterial
                        // 适中：.thinMaterial
                        // 较糊：.regularMaterial
                        .fill(.thinMaterial)
                        
                        // 旋钮 2：材质穿透率 (极少人知道的黑客技巧)
                        // 1.0 代表 100% 模糊遮挡。
                        // 如果你把它降到 0.7，意味着有 30% 的绝对清晰的背景画面会穿透上来！
                        // 💡 想增加通透感，把这里往下调（建议范围 0.75 ~ 1.0）
                        .opacity(0.8)
                    
                    // ==========================================
                    // 🎛️ 旋钮 3：控制【实体厚度】与【色彩浓度】
                    // ==========================================
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        // 旋钮 3：染色层浓度 (就像给玻璃贴膜)
                        // 数字越大，玻璃越像实心的白板/黑板；数字越小，越像空气。
                        // 💡 感觉不够透？继续降低这里的 opacity 参数！(建议降到 0.05 ~ 0.15)
                        .fill(isDark ? Color.black.opacity(0.1) : Color.white.opacity(0.1))
                    
                    // 👉 边缘高光 (不用动，保持清晰边界)
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    .white.opacity(isDark ? 0.3 : 0.9),
                                    .white.opacity(isDark ? 0.05 : 0.3),
                                    .clear,
                                    isDark ? .black.opacity(0.6) : .black.opacity(0.1)
                                ],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ), lineWidth: 1.5
                        )
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

// ✨ 2. 修正后的液态输入框 (真正的物理内凹感)
struct LiquidInputModifier: ViewModifier {
    var isDark: Bool
    var cornerRadius: CGFloat = 12
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    // ✨ 物理纠正：无论是深色还是浅色，"内凹"意味着光线被遮挡，必须加黑色阴影！
                    .fill(isDark ? Color.black.opacity(0.4) : Color.black.opacity(0.06))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    // 内发光描边：模拟玻璃坑槽的边缘反光
                    .stroke(isDark ? Color.white.opacity(0.1) : Color.black.opacity(0.08), lineWidth: 1)
            )
    }
}

extension View {
    func liquidSheet(isDark: Bool) -> some View {
        self.modifier(LiquidSheetModifier(isDark: isDark))
    }
}
extension View {
    func liquidInput(isDark: Bool, cornerRadius: CGFloat = 12) -> some View {
        self.modifier(LiquidInputModifier(isDark: isDark, cornerRadius: cornerRadius))
    }
}
