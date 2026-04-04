import SwiftUI
import SwiftData

// MARK: - 📚 想读焦点：平行陈列架 (220px 高度适配版)
struct QueueBookshelfChart: View {
    @Environment(\.colorScheme) var colorScheme
    @Query(filter: #Predicate<Book> { $0.isWantToRead == true }) var wantToReadBooks: [Book]
    
    @State private var showItems = false
    
    var body: some View {
        let isDark = colorScheme == .dark
        let displayBooks = Array(wantToReadBooks.prefix(3))
        
        VStack(alignment: .leading, spacing: 2) { // ✨ 缩小间距
            // 🎯 头部区：稍微压缩垂直占用
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("想读焦点").font(.system(size: 16, weight: .bold, design: .rounded)).foregroundColor(isDark ? .white : .twSlate800)
                }
                Spacer()
                Image(systemName: "sparkles.rectangle.stack").font(.system(size: 14)).foregroundColor(.twOrange500)
            }
            
            // 🎯 核心陈列区
            if displayBooks.isEmpty {
                HStack { Spacer(); Text("暂无设定的想读焦点").font(.system(size: 12, weight: .bold)).foregroundColor(.twSlate500); Spacer() }.frame(maxHeight: .infinity)
            } else {
                Spacer(minLength: 0) // ✨ 灵活占位，将内容推向中间
                HStack(alignment: .top, spacing: 20) {
                    Spacer(minLength: 0)
                    ForEach(Array(displayBooks.enumerated()), id: \.element.id) { index, book in
                        WantToReadBookItem(book: book, index: index, isDark: isDark, showItems: showItems)
                    }
                    Spacer(minLength: 0)
                }
                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24) // ✨ 核心修复：垂直 Padding 缩减 8px
        .frame(height: 220)    // ✨ 核心修复：死死锁住 220 高度
        .homeStaticGlassCardStyle()
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) { showItems = true }
        }
    }
}

// MARK: - ✨ 专属子组件：想读焦点单本书 (紧凑适配版)
private struct WantToReadBookItem: View {
    let book: Book
    let index: Int
    let isDark: Bool
    let showItems: Bool
    
    @State private var isHovered = false
    @State private var dominantColor: Color = .twSlate400
    
    var body: some View {
        VStack(spacing: 8) { // ✨ 内部间距缩小
            
            // 1. 封面
            LocalCoverView(coverData: book.coverData, fallbackTitle: book.title)
                .frame(width: 80, height: 120) // ✨ 稍微从 86x129 缩减到 80x120，腾出 9px 垂直高度
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .shadow(color: dominantColor.opacity(isDark ? (isHovered ? 0.4 : 0.15) : (isHovered ? 0.25 : 0.08)), radius: isHovered ? 10 : 5, y: isHovered ? 5 : 2)
            
            // 2. 主色调能量条
            Capsule()
                .fill(dominantColor.gradient)
                .frame(width: 30, height: 3) // ✨ 细化条带
                .shadow(color: dominantColor.opacity(isHovered ? 0.5 : 0), radius: 3, y: 1)
            
            // 3. 书名
            Text(book.title)
                .font(.system(size: 11, weight: .bold)) // ✨ 字号缩小 1px
                .foregroundColor(isDark ? .twSlate300 : .twSlate700)
                .lineLimit(1)
                .frame(width: 80)
                .multilineTextAlignment(.center)
        }
        .offset(y: showItems ? 0 : 15)
        .opacity(showItems ? 1 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(Double(index) * 0.08), value: showItems)
        .offset(y: isHovered ? -4 : 0)
        .scaleEffect(isHovered ? 1.03 : 1.0)
        .animation(.spring(response: 0.35, dampingFraction: 0.6), value: isHovered)
        .onHover { h in isHovered = h }
        .pointingHand()
        .task(id: book.id) {
            let color = await CoverColorExtractor.shared.getDominantColor(from: book.coverData, id: book.id)
            withAnimation(.easeInOut(duration: 0.6)) { self.dominantColor = color }
        }
    }
}
