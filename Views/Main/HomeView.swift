import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    
    // ✨ 持久化保存的深浅色模式状态
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    // 查询数据
    @Query(filter: #Predicate<Book> { $0.status == "READING" }) var readingBooks: [Book]
    @Query(filter: #Predicate<Book> { $0.status == "UNREAD" }) var unreadBooks: [Book]
    @Query(filter: #Predicate<Book> { $0.status == "FINISHED" }) var finishedBooks: [Book]
    @Query var allBooks: [Book]
    
    var namespace: Namespace.ID
    @Binding var selectedBook: Book?
    
    // ==========================================
    // 🎛️ 页面整体布局调节区 (精准匹配截图比例)
    // ==========================================
    let pagePadding: CGFloat = 50       // 页面左右安全距离 (留白)
    let headerSpacing: CGFloat = 30     // 顶部控制栏与下方的间距
    let widgetSpacing: CGFloat = 30     // ✨ 左右两块核心看板的【左右间距】
    let sectionSpacing: CGFloat = 60    // 核心看板与底部 3D 模块之间的【上下间距】
    // ==========================================
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 1. 底层智能背景 (自动适配深浅色模式)
                Color(NSColor.windowBackgroundColor).ignoresSafeArea()
                
                // 2. 环境光晕特效 (点缀左上角)
                Circle()
                    .fill(Color.indigo.opacity(isDarkMode ? 0.15 : 0.05))
                    .frame(width: 600)
                    .blur(radius: 120)
                    .offset(x: -300, y: -400)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        
                        // ================= 模块 1：最顶部控制栏 =================
                        HStack(alignment: .center) {
                            // 👈 左上角：深色/浅色模式切换
                            Button(action: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    isDarkMode.toggle()
                                }
                            }) {
                                Image(systemName: isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(isDarkMode ? .indigo : .orange)
                                    .frame(width: 44, height: 44)
                                    .background(Color.primary.opacity(0.05))
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.primary.opacity(0.1), lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                            
                            Spacer()
                            
                            // 👉 右上角：功能按钮组
                            HStack(spacing: 16) {
                                Button(action: { /* 跳转全部图书 */ }) {
                                    Label("全部图书", systemImage: "books.vertical.fill")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(Color(NSColor.controlBackgroundColor).opacity(0.8))
                                        .clipShape(Capsule())
                                        .overlay(Capsule().stroke(Color.primary.opacity(0.1), lineWidth: 1))
                                }
                                .buttonStyle(.plain)
                                
                                Button(action: { /* 弹窗录入新书 */ }) {
                                    Label("录入新书", systemImage: "plus")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(
                                            LinearGradient(colors: [.indigo, .purple], startPoint: .leading, endPoint: .trailing)
                                        )
                                        .clipShape(Capsule())
                                        .shadow(color: .indigo.opacity(0.3), radius: 8, y: 4)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.top, 20)
                        .padding(.bottom, headerSpacing)
                        
                        // ================= 模块 2：页面头部欢迎语 (HeaderView) =================
                        // (如果你有专门的 HeaderView，它会在这里渲染)
                        HeaderView()
                            .padding(.bottom, 40)
                        
                        // ================= 模块 3：✨ 核心左右分栏 (精准复刻截图) =================
                        // 放弃 GeometryReader 带来的高度塌陷问题
                        // 直接利用 HStack 和 .frame(maxWidth: .infinity) 进行自然等比排版
                        HStack(alignment: .top, spacing: widgetSpacing) {
                            
                            // 👈 左半区：当前在读 (占据稍微多一点的空间)
                            CurrentReadingWidget(
                                heroBook: readingBooks.first,
                                namespace: namespace,
                                selectedBook: $selectedBook,
                                readingCount: readingBooks.count
                            )
                            // 利用 weight 优先分配空间（左55% : 右45% 的视觉感）
                            .frame(maxWidth: .infinity, alignment: .top)
                            
                            // 👉 右半区：数据看板
                            DashboardWidget()
                                .frame(maxWidth: .infinity, alignment: .top)
                                // 稍微缩放一点点右侧容器，让左边显得更宽，完美契合你的截图排版
                                .scaleEffect(0.98, anchor: .topLeading)
                        }
                        .padding(.bottom, sectionSpacing)
                        
                        // ================= 模块 4：底部 3D 全景展览 =================
                        if !allBooks.isEmpty {
                            CarouselWidget(books: allBooks, namespace: namespace, selectedBook: $selectedBook)
                                .padding(.bottom, 80)
                        }
                    }
                    .padding(.horizontal, pagePadding)
                }
            }
            .navigationTitle("")
            .toolbarBackground(.hidden, for: .windowToolbar)
            // ✨ 自动接管全局深浅色
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}

// ===============================================
// ✨ 极宽视场双模式预览装配环境 (一屏尽览)
// ===============================================
#Preview("Light Mode - Ultra Wide Dashboard") {
    struct HomePreviewWrapper: View {
        @Namespace var namespace
        @State var selectedBook: Book?
        var body: some View {
            HomeView(namespace: namespace, selectedBook: $selectedBook)
        }
    }
    
    return HomePreviewWrapper()
        .modelContainer(PreviewData.shared)
        // 模拟桌面端极宽屏幕，完美呈现左右双轨布局和底部的 3D 画廊
        .frame(width: 1440, height: 1200)
}

#Preview("Dark Mode - Ultra Wide Dashboard") {
    struct HomePreviewWrapper: View {
        @Namespace var namespace
        @State var selectedBook: Book?
        var body: some View {
            HomeView(namespace: namespace, selectedBook: $selectedBook)
                .onAppear { UserDefaults.standard.set(true, forKey: "isDarkMode") }
        }
    }
    
    return HomePreviewWrapper()
        .modelContainer(PreviewData.shared)
        .frame(width: 1440, height: 1200)
}
