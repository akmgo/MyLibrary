import SwiftUI

// 1. 统一的液态输入框修饰器 (内凹沉浸感)
struct LiquidInputModifier: ViewModifier {
    var isDark: Bool
    var cornerRadius: CGFloat = 12
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(isDark ? Color.black.opacity(0.3) : Color.white.opacity(0.3))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(isDark ? Color.white.opacity(0.1) : Color.black.opacity(0.06), lineWidth: 1)
            )
    }
}

extension View {
    func liquidInput(isDark: Bool, cornerRadius: CGFloat = 12) -> some View {
        self.modifier(LiquidInputModifier(isDark: isDark, cornerRadius: cornerRadius))
    }
}
