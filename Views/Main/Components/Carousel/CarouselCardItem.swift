import SwiftUI
import SwiftData

struct CarouselCardItem: View {
    let book: Book
    let index: Int
    let currentIndex: Int
    let totalCount: Int
    let selectedBook: Book?
    
    // ✨ 核心修复：彻底删除了这里的 namespace 和 activeCoverID 定义！
    
    // 🎛️ 尺寸对齐网页端
    let cardWidth: CGFloat = 220
    let cardHeight: CGFloat = 330
    
    var body: some View {
        var diff = index - currentIndex
        let half = totalCount / 2
        
        if diff > half { diff -= totalCount }
        if diff < -half { diff += totalCount }
        
        let absDiff = abs(diff)
        let isCenter = diff == 0
        
        let translateX = CGFloat(diff) * 120
        let rotateY = Double(diff) * -35
        let scale = isCenter ? 1.0 : max(1.0 - CGFloat(absDiff) * 0.15, 0.4)
        let cardOpacity = absDiff > 4 ? 0.0 : 1.0 - Double(absDiff) * 0.15
        
        return VStack(spacing: 24) {
            
            // ===================================
            // 封面区：封印贪婪视图的 ZStack
            // ===================================
            ZStack {
                LocalCoverView(coverData: book.coverData, fallbackTitle: book.title)
                    // ✨ 核心修复：移除了残余的 .matchedGeometryEffect
                
                // 黑化遮罩
                if !isCenter {
                    Color.black.opacity(min(0.6, Double(absDiff) * 0.2))
                }
                
                // 高光渐变
                LinearGradient(
                    colors: [.clear, .white.opacity(0.05), .white.opacity(0.2)],
                    startPoint: .bottomLeading,
                    endPoint: .topTrailing
                )
                
                // 边框描边
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            }
            .frame(width: cardWidth, height: cardHeight)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(
                color: isCenter ? Color.indigo.opacity(0.5) : Color.black.opacity(0.3),
                radius: isCenter ? 30 : 15,
                x: 0,
                y: isCenter ? 20 : 10
            )
            
            // ===================================
            // 底部文字区
            // ===================================
            VStack(spacing: 6) {
                Text(book.title)
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(book.author.uppercased())
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .tracking(2)
                    .foregroundColor(.indigo)
            }
            .frame(width: cardWidth + 80) // 给文字留出足够的展现空间
            .opacity(isCenter ? 1 : 0)
            .offset(y: isCenter ? 0 : 20)
            .blur(radius: isCenter ? 0 : 5)
        }
        .rotation3DEffect(.degrees(rotateY), axis: (x: 0, y: 1, z: 0), perspective: 0.8)
        .scaleEffect(scale)
        .offset(x: translateX, y: isCenter ? -10 : 0)
        .zIndex(Double(100 - absDiff))
        .opacity(cardOpacity)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentIndex)
    }
}
