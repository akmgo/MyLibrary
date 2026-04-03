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
    
    /// ✨ 新增：把摘录弹窗的控制权提到详情页这一层，确保它能覆盖全屏
    @State private var showAddExcerptSheet = false
    
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
            .zIndex(0)
            
            // ================= 2. 延迟出现的文本与内容层 =================
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 40) {
                    HStack {
                        HoverBackButton(isDark: isDarkMode) { closeDetail() }
                        Spacer()
                        HStack(spacing: 12) {
                            HoverEditButton(isDark: isDarkMode) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) { showEditSheet = true }
                            }
                            HoverDeleteButton(isDark: isDarkMode) { showDeleteAlert = true }
                        }
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : -20)
                    .zIndex(0)
                    
                    VStack(spacing: 40) {
                        BookDossierView(book: book, namespace: namespace, activeCoverID: activeCoverID, showContent: showContent)
                            .zIndex(999)
                        
                        // ✨ 传入控制开关
                        BookExcerptsView(book: book, showAddExcerpt: $showAddExcerptSheet)
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                            .zIndex(0)
                    }
                    .zIndex(999)
                }
                .padding(40)
                .zIndex(999)
            }
            .zIndex(999)
            
            // ================= 3. ✨ 编辑书籍弹窗引擎 =================
            if showEditSheet {
                ZStack(alignment: .center) {
                    Color.black.opacity(isDarkMode ? 0.5 : 0.2)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) { showEditSheet = false }
                        }
                        .transition(.opacity)
                        .zIndex(1)
                    
                    BookEditorSheet(isPresented: $showEditSheet, bookToEdit: book)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.9).combined(with: .opacity),
                            removal: .scale(scale: 0.9).combined(with: .opacity)
                        ))
                        .zIndex(2)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .zIndex(1000) // ✨ 盖在所有内容之上
            }
            
            // ================= 4. ✨ 新增摘录弹窗引擎 =================
            if showAddExcerptSheet {
                ZStack(alignment: .center) {
                    Color.black.opacity(isDarkMode ? 0.5 : 0.2)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) { showAddExcerptSheet = false }
                        }
                        .transition(.opacity)
                        .zIndex(1)
                    
                    AddExcerptSheet(isPresented: $showAddExcerptSheet, book: book)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.9).combined(with: .opacity),
                            removal: .scale(scale: 0.9).combined(with: .opacity)
                        ))
                        .zIndex(2)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .zIndex(1001) // ✨ 盖在所有内容之上
            }
            
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            withAnimation(.easeOut(duration: 0.15)) { showBackground = true }
            withAnimation(.easeOut(duration: 0.3).delay(0.2)) { showContent = true }
        }
        .alert("删除书籍", isPresented: $showDeleteAlert) {
            Button("取消", role: .cancel) {}
            Button("确认删除", role: .destructive) {
                closeDetail()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { modelContext.delete(book) }
            }
        } message: {
            Text("确定要删除《\(book.title)》吗？相关的读书笔记也会一并清除。")
        }
    }
    
    private func closeDetail() {
        withAnimation(.easeOut(duration: 0.15)) { showContent = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            withAnimation(.easeOut(duration: 0.2)) { showBackground = false }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { selectedBook = nil }
        }
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
