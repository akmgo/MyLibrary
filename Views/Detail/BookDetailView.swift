import SwiftUI
import SwiftData

struct BookDetailView: View {
    let book: Book
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var body: some View {
        ZStack {
            // ================= 1. 全局环境光 =================
            (isDarkMode ? Color.twSlate950 : Color.twSlate50).ignoresSafeArea()
            
            GeometryReader { geo in
                ZStack {
                    Circle().fill(isDarkMode ? Color.twIndigo600.opacity(0.15) : Color.twSky300.opacity(0.2)).frame(width: 600, height: 600).blur(radius: 120).position(x: 0, y: 0)
                    Circle().fill(isDarkMode ? Color.twPurple600.opacity(0.15) : Color.twFuchsia300.opacity(0.2)).frame(width: 600, height: 600).blur(radius: 120).position(x: geo.size.width, y: geo.size.height)
                    if !isDarkMode {
                        Circle().fill(Color.twAmber200.opacity(0.2)).frame(width: 500, height: 500).blur(radius: 120).position(x: geo.size.width * 0.2, y: geo.size.height * 0.4)
                    }
                }
            }.ignoresSafeArea()
            
            // ================= 2. 主体内容 (上下堆叠，可滚动) =================
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 40) {
                    
                    // 顶部返回按钮
                    Button(action: { dismiss() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.left").font(.system(size: 16, weight: .bold))
                            Text("返回书架").font(.system(size: 15, weight: .bold))
                        }
                        .foregroundColor(isDarkMode ? .twSlate300 : .twSlate600)
                        .padding(.horizontal, 20).padding(.vertical, 12)
                        .background(isDarkMode ? Color.twSlate800.opacity(0.6) : Color.white.opacity(0.6)).background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(isDarkMode ? Color.white.opacity(0.05) : Color.white.opacity(0.6), lineWidth: 1))
                        .shadow(color: .black.opacity(isDarkMode ? 0.2 : 0.05), radius: 10, y: 4)
                    }
                    .buttonStyle(.plain)
                    
                    // ✨ 核心上下布局区块
                    VStack(spacing: 40) {
                        // 上方：封面与详情
                        BookDossierView(book: book)
                        
                        // 下方：书摘流
                        BookExcerptsView(book: book)
                    }
                }
                .padding(40)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

// ===============================================
// ✨ 详情页极宽预览环境
// ===============================================
#Preview("Light Mode - Book Detail") {
    let mockBook = Book(title: "中国人的精神", author: "辜鸿铭", status: "READING", tags: [])
    return BookDetailView(book: mockBook)
        .frame(width: 1100, height: 900)
        .preferredColorScheme(.light)
}

#Preview("Dark Mode - Book Detail") {
    let mockBook = Book(title: "理想国", author: "柏拉图", status: "FINISHED", tags: [])
    return BookDetailView(book: mockBook)
        .onAppear { UserDefaults.standard.set(true, forKey: "isDarkMode") }
        .frame(width: 1100, height: 900)
        .preferredColorScheme(.dark)
}
