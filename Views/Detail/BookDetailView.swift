import SwiftData
import SwiftUI

struct BookDetailView: View {
    let book: Book
    let namespace: Namespace.ID
    @Binding var activeCoverID: String
    @Binding var selectedBook: Book?
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    @State private var showBackground = false
    @State private var showContent = false
    
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    
    var body: some View {
        ZStack {
            // ================= 1. 瞬间覆盖的背景层 =================
            ZStack {
                (isDarkMode ? Color.twSlate950 : Color.twSlate50).ignoresSafeArea()
                GeometryReader { geo in
                    ZStack {
                        Circle().fill(isDarkMode ? Color.twIndigo600.opacity(0.15) : Color.twSky300.opacity(0.2)).frame(width: 600, height: 600).blur(radius: 120).position(x: 0, y: 0)
                        Circle().fill(isDarkMode ? Color.twPurple600.opacity(0.15) : Color.twFuchsia300.opacity(0.2)).frame(width: 600, height: 600).blur(radius: 120).position(x: geo.size.width, y: geo.size.height)
                    }
                }.ignoresSafeArea()
            }
            .opacity(showBackground ? 1 : 0)
            .zIndex(0) // ✨ 背景最底层
            
            // ================= 2. 延迟出现的文本与内容层 =================
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 40) {
                    HStack {
                        // 左侧：返回按钮
                        Button(action: { closeDetail() }) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.left").font(.system(size: 16, weight: .bold))
                                Text("返回书架").font(.system(size: 15, weight: .bold))
                            }
                            .foregroundColor(isDarkMode ? .twSlate300 : .twSlate600)
                            .padding(.horizontal, 20).padding(.vertical, 12)
                            .background(isDarkMode ? Color.twSlate800.opacity(0.6) : Color.white.opacity(0.6))
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(isDarkMode ? Color.white.opacity(0.05) : Color.white.opacity(0.6), lineWidth: 1))
                            .shadow(color: .black.opacity(isDarkMode ? 0.2 : 0.05), radius: 10, y: 4)
                        }
                        .buttonStyle(.plain)
                                            
                        Spacer() // ✨ 把左右两边推开！
                                            
                        // 右侧：编辑和删除操作区
                        HStack(spacing: 12) {
                            Button(action: { showEditSheet = true }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "pencil")
                                    Text("编辑")
                                }
                            }
                            .buttonStyle(DetailActionButtonStyle(isDark: isDarkMode, role: .edit))
                                                
                            Button(action: { showDeleteAlert = true }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "trash")
                                    Text("删除")
                                }
                            }
                            .buttonStyle(DetailActionButtonStyle(isDark: isDarkMode, role: .delete))
                        }
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : -20)
                    .zIndex(0)
                    
                    VStack(spacing: 40) {
                        BookDossierView(book: book, namespace: namespace, activeCoverID: activeCoverID, showContent: showContent)
                            .zIndex(999) // ✨
                        
                        BookExcerptsView(book: book)
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                            .zIndex(0) // ✨ 摘录区必定在下层
                    }
                    .zIndex(999) // ✨
                }
                .padding(40)
                .zIndex(999) // ✨
            }
            .zIndex(999) // ✨ 保证整个 ScrollView 能够容纳起飞元素
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            withAnimation(.easeOut(duration: 0.15)) { showBackground = true }
            withAnimation(.easeOut(duration: 0.3).delay(0.2)) { showContent = true }
        }
        .sheet(isPresented: $showEditSheet) {
            BookEditorSheet(bookToEdit: book) // 传参：编辑模式
        }
        .alert("删除书籍", isPresented: $showDeleteAlert) {
            Button("取消", role: .cancel) {}
            Button("确认删除", role: .destructive) {
                // 先触发飞回动画关闭详情页
                closeDetail()
                // 延迟一小下再删数据，防止动画找不到数据源崩溃
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    modelContext.delete(book)
                }
            }
        } message: {
            Text("确定要删除《\(book.title)》吗？相关的读书笔记也会一并清除。")
        }
    }
    
    private func closeDetail() {
        withAnimation(.easeOut(duration: 0.15)) { showContent = false }
            
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.easeOut(duration: 0.2)) { showBackground = false }
                
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                selectedBook = nil
            }
        }
    }
}

struct DetailActionButtonStyle: ButtonStyle {
    var isDark: Bool
    var role: Role
    enum Role { case edit, delete }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(role == .delete ? .red : (isDark ? .twSlate300 : .twSlate600))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(isDark ? Color.twSlate800.opacity(0.6) : Color.white.opacity(0.6))
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(role == .delete ? Color.red.opacity(0.3) : (isDark ? Color.white.opacity(0.05) : Color.white.opacity(0.6)), lineWidth: 1))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

/// 预览 Wrapper
struct BookDetailPreviewWrapper: View {
    let book: Book
    @Namespace var namespace
    @State var selectedBook: Book? = nil
    @State var activeCoverID: String = "preview" // ✨ 增加 @State
    
    var body: some View {
        BookDetailView(book: book, namespace: namespace, activeCoverID: $activeCoverID, selectedBook: $selectedBook) // ✨ 加 $
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
