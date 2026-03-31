import SwiftUI

struct BoomDecorCard: View {
    @State private var isHovered = false
    
    var body: some View {
        ZStack(alignment: .leading) {
            // ================= 1. 背景层 =================
            ZStack {
                if isHovered {
                    // 悬浮时：炫酷渐变
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(LinearGradient(
                            colors: [Color.indigo, Color.purple.opacity(0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .transition(.opacity) // 平滑切换背景
                } else {
                    // 正常时：磨砂玻璃材质
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color(NSColor.controlBackgroundColor).opacity(0.4))
                        .background(.regularMaterial)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.white.opacity(isHovered ? 0.2 : 0.1), lineWidth: 1)
            )
            .shadow(color: Color.indigo.opacity(isHovered ? 0.3 : 0), radius: 20, x: 0, y: 10)
            
            // ================= 2. 扫光特效 =================
            GeometryReader { geo in
                Rectangle()
                    .fill(LinearGradient(
                        colors: [.clear, .white.opacity(0.3), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(width: 150)
                    .rotationEffect(.degrees(15))
                    .offset(x: isHovered ? geo.size.width + 100 : -200)
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            
            // ================= 3. 内容层 =================
            HStack(spacing: 20) {
                // 左侧文字区
                VStack(alignment: .leading, spacing: 6) {
                    Text("“读书，是一场随身携带的避难所。”")
                        .font(.system(size: 24, weight: .black, design: .serif))
                        .foregroundColor(isHovered ? .white : .primary)
                        // ✨ 已移除模糊：现在正常状态也是清晰的
                        .opacity(isHovered ? 1.0 : 0.9)
                        .scaleEffect(isHovered ? 1.02 : 1.0, anchor: .leading)
                    
                    Text("W.S. MAUGHAM")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .tracking(3)
                        .foregroundColor(isHovered ? Color.white.opacity(0.8) : .secondary)
                }
                
                Spacer()
                
                // 右侧动态图标
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(isHovered ? 0.2 : 0))
                        .frame(width: 64, height: 64)
                        .blur(radius: 15)
                    
                    Image(systemName: "pencil.and.outline")
                        .font(.system(size: 36, weight: .light))
                        .foregroundColor(isHovered ? .white : .secondary.opacity(0.8))
                        .scaleEffect(isHovered ? 1.2 : 1.0)
                        .rotationEffect(.degrees(isHovered ? -15 : 0))
                }
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 24)
        }
        .frame(height: 120)
        .contentShape(Rectangle()) // 确保整个区域都能触发 Hover
        .onHover { hovering in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                isHovered = hovering
            }
        }
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
