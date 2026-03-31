import SwiftUI
import SwiftData

struct CurrentReadingWidget: View {
    let heroBook: Book?
    let namespace: Namespace.ID
    @Binding var selectedBook: Book?
    var readingCount: Int = 1
    
    var body: some View {
        ZStack {
            // ================= 1. 极速光晕背景 =================
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(Color(NSColor.windowBackgroundColor).opacity(0.6))
                .background(.ultraThinMaterial)
            
            Circle().fill(Color.blue.opacity(0.15)).frame(width: 400, height: 400).blur(radius: 80).offset(x: -200, y: -150)
            Circle().fill(Color.purple.opacity(0.15)).frame(width: 300, height: 300).blur(radius: 80).offset(x: 200, y: 150)
            
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                // ✨ 修复 1：将 .clear 改为明确的 Color.clear，以及 Color.white，根除编译器类型推导卡死的隐患
                .stroke(LinearGradient(colors: [Color.white.opacity(0.5), Color.clear, Color.white.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
            
            // ================= 2. 核心积木拼装 =================
            VStack(spacing: 20) {
                HStack {
                    Text("当前在读").font(.system(size: 24, weight: .bold, design: .rounded)).foregroundColor(.primary)
                    Spacer()
                    Text("\(readingCount) 本").font(.subheadline).fontWeight(.medium).foregroundColor(.secondary)
                }
                
                if let book = heroBook {
                    VStack(spacing: 20) {
                        HStack(spacing: 20) {
                            HeroBookCard(book: book, namespace: namespace, selectedBook: $selectedBook)
                                .frame(maxWidth: .infinity)
                            ReadingProgressCard(book: book)
                                .frame(width: 240)
                        }
                        BoomDecorCard()
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "book.closed").font(.system(size: 48)).foregroundColor(.secondary.opacity(0.3))
                        Text("目前没有正在阅读的书籍").font(.headline).italic().foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding(30)
        }
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        // ✨ 修复 2：显式声明 Color.black
        .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
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
