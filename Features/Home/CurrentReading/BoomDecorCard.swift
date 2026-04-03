import SwiftUI

struct BoomDecorCard: View {
    @State private var isHovered = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        let isDark = colorScheme == .dark
        ZStack(alignment: .leading) {
            if isHovered {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(LinearGradient(colors: [Color.twIndigo500, Color.twPurple600], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .transition(.opacity)
            }
            
            GeometryReader { geo in
                Rectangle().fill(LinearGradient(colors: [.clear, .white.opacity(0.3), .clear], startPoint: .leading, endPoint: .trailing)).frame(width: 150).rotationEffect(.degrees(15)).offset(x: isHovered ? geo.size.width + 100 : -200)
            }.clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("“读书，是一场随身携带的避难所。”").font(.system(size: 24, weight: .black, design: .serif)).foregroundColor(isHovered ? .white : .primary).scaleEffect(isHovered ? 1.02 : 1.0, anchor: .leading)
                    Text("W.S. MAUGHAM").font(.system(size: 12, weight: .bold, design: .rounded)).tracking(3).foregroundColor(isHovered ? Color.white.opacity(0.8) : .twSlate400)
                }
                Spacer()
                ZStack {
                    Circle().fill(Color.white.opacity(isHovered ? 0.2 : 0)).frame(width: 64, height: 64).blur(radius: 15)
                    Image(systemName: "pencil.and.outline").font(.system(size: 36, weight: .light)).foregroundColor(isHovered ? .white : (isDark ? .twSlate500 : .twSlate400)).scaleEffect(isHovered ? 1.2 : 1.0).rotationEffect(.degrees(isHovered ? -15 : 0))
                }
            }
            .padding(.horizontal, 30).padding(.vertical, 24)
        }
        .frame(height: 120).contentShape(Rectangle())
        .innerGlassCardStyle(isHovered: isHovered)
        .onHover { h in withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { isHovered = h } }
    }
}

// ===============================================
// ✨ 独立预览：包含深色模式和浅色模式
// ===============================================
#Preview("Light Mode") {
    BoomDecorCard()
        .padding()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    BoomDecorCard()
        .padding()
        .preferredColorScheme(.dark)
        .background(Color.black.ignoresSafeArea())
}
