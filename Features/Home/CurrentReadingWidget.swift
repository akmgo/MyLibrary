import SwiftUI
import SwiftData

struct CurrentReadingWidget: View {
    let heroBook: Book?
    let namespace: Namespace.ID
    @Binding var selectedBook: Book?
    @Binding var activeCoverID: String
    var readingCount: Int = 1
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        let isDark = colorScheme == .dark
        
        ZStack {
            // 光晕底层
            GeometryReader { geo in
                Circle().fill(isDark ? Color.twBlue600.opacity(0.1) : Color.twBlue300.opacity(0.3)).frame(width: 500, height: 500).blur(radius: 100).position(x: 0, y: 0)
                Circle().fill(isDark ? Color.twPurple600.opacity(0.1) : Color.twPurple300.opacity(0.3)).frame(width: 400, height: 400).blur(radius: 100).position(x: geo.size.width, y: geo.size.height)
            }.allowsHitTesting(false)
            
            VStack(spacing: 15) {
                // 1. 标题栏 (同样去掉多余的左右边距)
                HStack {
                    Text("当前在读").font(.system(size: 24, weight: .regular)).foregroundColor(isDark ? .white : .twSlate800)
                    Spacer()
                }
                .frame(height: 44)
                
                if let book = heroBook {
                    // 去掉了原先包裹着这些组件且自带 padding(15) 的多余 VStack
                    HStack(spacing: 24) {
                        HeroBookCard(book: book, namespace: namespace, selectedBook: $selectedBook, activeCoverID: $activeCoverID)
                            .frame(maxWidth: .infinity)
                        
                        ReadingProgressCard(book: book)
                            .frame(width: 200)
                    }
                    
                    // ✨ 魔法 2：利用 Spacer 将爆点装饰卡片强行推到最底部
                    Spacer(minLength: 0)
                    
                    BoomDecorCard()
                    
                } else {
                    Spacer(minLength: 0)
                    VStack(spacing: 16) {
                        Image(systemName: "book.closed").font(.system(size: 48)).foregroundColor(.twSlate400.opacity(0.3))
                        Text("目前没有正在阅读的书籍").font(.headline).italic().foregroundColor(.twSlate500)
                    }
                    Spacer(minLength: 0)
                }
            }
            // ✨ 魔法 1：与数据看板一模一样的内边距 (32)
            .padding(30)
        }
        // ✨ 魔法 3：开启高度拉伸，与隔壁数据看板齐平
        .frame(maxHeight: .infinity)
        .outerGlassBlockStyle()
    }
}

