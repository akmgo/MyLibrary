import SwiftUI

struct LiquidButtonModifier: ViewModifier {
    var cornerRadius: CGFloat
    var isDark: Bool
    var tintColor: Color?
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.thinMaterial)
                        .opacity(0.9)
                    
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(tintColor ?? Color.clear)
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(isDark ? 0.3 : 0.6),
                                .white.opacity(0.1),
                                .white.opacity(isDark ? 0.05 : 0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

extension View {
    func liquidButtonGlass(cornerRadius: CGFloat = 12, isDark: Bool = false, tintColor: Color? = nil) -> some View {
        self.modifier(LiquidButtonModifier(cornerRadius: cornerRadius, isDark: isDark, tintColor: tintColor))
    }
}
