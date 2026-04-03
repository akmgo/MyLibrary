import SwiftUI

// ✨ 完美平衡版：适度通透 + 凸透镜边缘形变错觉
struct LiquidGlassModifier: ViewModifier {
    var cornerRadius: CGFloat
    var isDark: Bool
    var tintColor: Color? = nil
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // ✨ 1. 减弱透射：将 0.75 提升至 0.9
                    // 恢复了高档玻璃的厚重感，不再显得过于“赤裸”
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.thickMaterial)
                        .opacity(0.96)
                    
                    // 2. 极微弱的染色层
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(tintColor?.opacity(isDark ? 0.05 : 0.02) ?? Color.clear)
                        
                    // ✨ 3. 核心光学错觉：凸透镜体积折射层！
                    // 中间完全透明，四周边缘呈现圆环状的高亮/深邃渐变。
                    // 当底层元素滑过边缘时，会产生强烈的“被曲面拉扯”的视觉形变。
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            RadialGradient(
                                colors: [
                                    .clear,
                                    .clear,
                                    isDark ? .black.opacity(0.4) : .white.opacity(0.6)
                                ],
                                center: .center,
                                startRadius: cornerRadius * 0.5,
                                endRadius: cornerRadius * 2.5
                            )
                        )
                }
            )
            // 4. 清晰硬朗的高光边框 (保持 1.0)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                isDark ? .white.opacity(0.5) : .white.opacity(1.0),
                                isDark ? .white.opacity(0.05) : .white.opacity(0.4),
                                .clear,
                                isDark ? .black.opacity(0.5) : .black.opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.0
                    )
            )
            // ✨ 5. 新增：厚切玻璃的内折射切面
            // 进一步增强边缘的物理体积感，让水滴看起来“鼓”起来
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(isDark ? .black.opacity(0.5) : .white.opacity(0.8), lineWidth: 3)
                    .blur(radius: 3)
                    // 使用 mask 确保模糊效果只向内发散
                    .mask(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

extension View {
    func liquidGlass(cornerRadius: CGFloat = 16, isDark: Bool = false, tintColor: Color? = nil) -> some View {
        modifier(LiquidGlassModifier(cornerRadius: cornerRadius, isDark: isDark, tintColor: tintColor))
    }
}
