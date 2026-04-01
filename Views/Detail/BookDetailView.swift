import SwiftUI
import SwiftData

struct BookDetailView: View {
    let book: Book
    let namespace: Namespace.ID
    let activeCoverID: String
    @Binding var selectedBook: Book?
    
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    // ✨ 状态拆分大招
    @State private var showBackground = false // 控制背景大遮罩
    @State private var showContent = false    // 控制返回按钮和文字
    
    var body: some View {
        ZStack {
            // ================= 1. 瞬间覆盖的背景层 =================
            ZStack {
                (isDarkMode ? Color.twSlate950 : Color.twSlate50)
                    .ignoresSafeArea()
                GeometryReader { geo in
                    ZStack {
                        Circle()
                            .fill(isDarkMode ? Color.twIndigo600.opacity(0.15) : Color.twSky300.opacity(0.2))
                            .frame(width: 600, height: 600)
                            .blur(radius: 120)
                            .position(x: 0, y: 0)
                        Circle()
                            .fill(isDarkMode ? Color.twPurple600.opacity(0.15) : Color.twFuchsia300.opacity(0.2))
                            .frame(width: 600, height: 600)
                            .blur(radius: 120)
                            .position(x: geo.size.width, y: geo.size.height)
                    }
                }
                .ignoresSafeArea()
            }
            .opacity(showBackground ? 1 : 0) // 由 showBackground 控制
            
            // ================= 2. 延迟出现的文本与内容层 =================
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 40) {
                    
                    Button(action: { closeDetail() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 16, weight: .bold))
                            Text("返回书架")
                                .font(.system(size: 15, weight: .bold))
                        }
                        .foregroundColor(isDarkMode ? .twSlate300 : .twSlate600)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(isDarkMode ? Color.twSlate800.opacity(0.6) : Color.white.opacity(0.6))
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(isDarkMode ? Color.white.opacity(0.05) : Color.white.opacity(0.6), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(isDarkMode ? 0.2 : 0.05), radius: 10, y: 4)
                    }
                    .buttonStyle(.plain)
                    // 返回按钮跟内容一起浮现，不显得突兀
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : -20)
                    
                    VStack(spacing: 40) {
                        BookDossierView(book: book, namespace: namespace, activeCoverID: activeCoverID, showContent: showContent)
                        BookExcerptsView(book: book)
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                    }
                }
                .padding(40)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // ✨ 进场时序：背景瞬间遮罩，内容稍作等待
            withAnimation(.easeOut(duration: 0.15)) { showBackground = true }
            withAnimation(.easeOut(duration: 0.3).delay(0.2)) { showContent = true }
        }
    }
    
    private func closeDetail() {
        // ✨ 退回时序管理：
        // 1. 先让文字和毛玻璃瞬间消失，干干净净
        withAnimation(.easeOut(duration: 0.15)) { showContent = false }
        
        // 2. 稍微延迟 0.15 秒（等文字散完），让全局背景平滑淡出，同时立刻触动 selectedBook = nil 开始飞回！
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.easeOut(duration: 0.2)) { showBackground = false }
            
            // 采用和飞入一模一样的参数，保证回落轨迹自然
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { selectedBook = nil }
        }
    }
}

// 预览 Wrapper
struct BookDetailPreviewWrapper: View {
    let book: Book
    @Namespace var namespace
    @State var selectedBook: Book? = nil
    var body: some View {
        BookDetailView(book: book, namespace: namespace, activeCoverID: "preview", selectedBook: $selectedBook)
    }
}

#Preview("Light Mode - Book Detail") {
    BookDetailPreviewWrapper(book: Book(title: "中国人的精神", author: "辜鸿铭", status: "READING", tags: []))
        .frame(width: 1400, height: 950)
        .preferredColorScheme(.light)
}

#Preview("Dark Mode - Book Detail") {
    BookDetailPreviewWrapper(book: Book(title: "理想国", author: "柏拉图", status: "FINISHED", tags: []))
        .frame(width: 1400, height: 950)
        .preferredColorScheme(.dark)
}
