import SwiftUI
import SwiftData

struct CurrentReadingWidget: View {
    let heroBook: Book?
    let namespace: Namespace.ID
    @Binding var selectedBook: Book?
    var readingCount: Int = 1
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        let isDark = colorScheme == .dark
        ZStack {
            // 光晕放底层
            GeometryReader { geo in
                Circle().fill(isDark ? Color.twBlue600.opacity(0.1) : Color.twBlue300.opacity(0.3)).frame(width: 500, height: 500).blur(radius: 100).position(x: 0, y: 0)
                Circle().fill(isDark ? Color.twPurple600.opacity(0.1) : Color.twPurple300.opacity(0.3)).frame(width: 400, height: 400).blur(radius: 100).position(x: geo.size.width, y: geo.size.height)
            }.allowsHitTesting(false)
            
            VStack(spacing: 24) {
                HStack {
                    Text("当前在读").font(.system(size: 24, weight: .black)).foregroundColor(isDark ? .white : .twSlate800)
                    Spacer()
                    Text("\(readingCount) 本").font(.system(size: 14, weight: .bold)).foregroundColor(isDark ? .twSlate300 : .twSlate500)
                }
                .padding(.horizontal, 4)
                
                if let book = heroBook {
                    VStack(spacing: 24) {
                        HStack(spacing: 24) {
                            HeroBookCard(book: book, namespace: namespace, selectedBook: $selectedBook).frame(maxWidth: .infinity)
                            ReadingProgressCard(book: book).frame(width: 260)
                        }
                        BoomDecorCard()
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "book.closed").font(.system(size: 48)).foregroundColor(.twSlate400.opacity(0.3))
                        Text("目前没有正在阅读的书籍").font(.headline).italic().foregroundColor(.twSlate500)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding(40)
        }
        .outerGlassBlockStyle()
    }
}

// ✨ 最终装配厂预览
#Preview("总装配效果") {
    @Previewable @State var selectedBook: Book? = nil
    @Previewable @Namespace var namespace
    
    CurrentReadingWidget(
        // ✨ 修复 3：绝对不能直接写 Book(...)，改用我们上一步创建的全局安全模拟数据
        heroBook: PreviewData.mockBook,
        namespace: namespace,
        selectedBook: $selectedBook,
        readingCount: 3
    )
    .padding(40)
    .frame(width: 800) // 给一个足够宽的环境看拼装效果
    .background(Color.gray.opacity(0.1).ignoresSafeArea())
    // ✨ 修复 4：为预览视图注入模拟数据库环境，防止底层崩溃
    .modelContainer(PreviewData.shared)
}
