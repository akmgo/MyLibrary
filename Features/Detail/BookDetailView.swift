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
    @State private var showAddExcerptSheet = false
    
    @State private var isHoveredTheme = false
    
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
                        
                        BookExcerptsView(book: book, showAddExcerpt: $showAddExcerptSheet)
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                            .zIndex(0)
                    }
                    .zIndex(999)
                }
                .padding(.horizontal, 40).padding(.bottom, 40).padding(.top, 80)
                .zIndex(999)
            }
            .zIndex(999)
            .ignoresSafeArea(edges: .top)
            
            // ================= 3. ✨ 专属注入：详情页全局深浅色切换按钮 =================
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { isDarkMode.toggle() }
                    }) {
                        Image(systemName: isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(isDarkMode ? .twSky400 : .orange)
                            .frame(width: 40, height: 40)
                            .liquidCircleGlass(isHovered: isHoveredTheme, isDark: isDarkMode)
                    }
                    .buttonStyle(.plain)
                    .pointingHand()
                    .onHover { h in withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) { isHoveredTheme = h } }
                }
                Spacer()
            }
            .padding(.top, 10)
            .padding(.trailing, 10)
            .opacity(showContent ? 1 : 0) // ✨ 伴随详情页的内容一起丝滑淡入
            .zIndex(1000) // 赋予详情页内部的最高层级，绝对不会被遮挡！
            
            // ================= 3. ✨ 编辑书籍弹窗引擎 =================
            if showEditSheet {
                ZStack(alignment: .center) {
                    Color.black.opacity(isDarkMode ? 0.5 : 0.2).ignoresSafeArea()
                        .onTapGesture { withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) { showEditSheet = false } }
                        .transition(.opacity).zIndex(1)
                    
                    BookEditorSheet(isPresented: $showEditSheet, bookToEdit: book)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                        .transition(.asymmetric(insertion: .scale(scale: 0.9).combined(with: .opacity), removal: .scale(scale: 0.9).combined(with: .opacity)))
                        .zIndex(2)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity).zIndex(1000)
            }
            
            // ================= 4. ✨ 新增摘录弹窗引擎 =================
            if showAddExcerptSheet {
                ZStack(alignment: .center) {
                    Color.black.opacity(isDarkMode ? 0.5 : 0.2).ignoresSafeArea()
                        .onTapGesture { withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) { showAddExcerptSheet = false } }
                        .transition(.opacity).zIndex(1)
                    
                    AddExcerptSheet(isPresented: $showAddExcerptSheet, book: book)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                        .transition(.asymmetric(insertion: .scale(scale: 0.9).combined(with: .opacity), removal: .scale(scale: 0.9).combined(with: .opacity)))
                        .zIndex(2)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity).zIndex(1001)
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
        } message: { Text("确定要删除《\(book.title)》吗？相关的读书笔记也会一并清除。") }
    }
    
    /// ✨ 完全还原成功版本的退出逻辑，完美解决画廊返回缩放畸变问题！
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
    @State var activeCoverID: String = "preview"
    var body: some View {
        BookDetailView(book: book, namespace: namespace, activeCoverID: $activeCoverID, selectedBook: $selectedBook)
    }
}
