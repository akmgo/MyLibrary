import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    @Query(filter: #Predicate<Book> { $0.status == "READING" }) var readingBooks: [Book]
    @Query(filter: #Predicate<Book> { $0.status == "UNREAD" }) var unreadBooks: [Book]
    @Query(filter: #Predicate<Book> { $0.status == "FINISHED" }) var finishedBooks: [Book]
    @Query var allBooks: [Book]
    
    let pagePadding: CGFloat = 30
    let widgetSpacing: CGFloat = 60
    let sectionSpacing: CGFloat = 60
    let topSpacing: CGFloat = 60
    
    @Namespace private var namespace
    @State private var selectedBook: Book? = nil
    
    /// ✨ 精准记录来源的 ID
    @State private var activeCoverID: String = ""
    
    @State private var showAddModal = false
    
    @State private var currentMainTab: String = "阅读主页"
    @Namespace private var mainTabNamespace
    
    /// ✨ Apple Music 风格：带图标的导航数据源
    let mainTabs = [
        ("阅读主页", "house.fill"),
        ("全景画廊", "square.grid.2x2.fill"),
        ("3D漫游", "view.3d"), // ✨ 新增的 3D 展览模块
        ("年度轨迹", "timelapse"),
        ("月度记录", "calendar")
    ]
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // ================= 1. 绝对底层：全局统一静止背景 =================
                FluidBackgroundView(isDark: isDarkMode)
                
                // ================= 2. 透明内容层：动态路由 =================
                Group {
                    switch currentMainTab {
                    case "阅读主页":
                        homeScrollContent
                    case "全景画廊":
                        ArchiveGalleryView(books: allBooks, namespace: namespace, selectedBook: $selectedBook, activeCoverID: $activeCoverID)
                    case "3D漫游": // ✨ 新增单独的 3D 页面封装
                        ZStack {
                            if allBooks.isEmpty {
                                Text("暂无书籍，去主页录入第一本吧").foregroundColor(.twSlate500)
                            } else {
                                CarouselWidget(books: allBooks)
                                    // 让它在全屏居中显示
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                        .padding(.top, 100) // 避开顶部导航栏
                    case "年度轨迹":
                        YearlyTimelineView(books: allBooks, namespace: namespace, selectedBook: $selectedBook, activeCoverID: $activeCoverID)
                    case "月度记录":
                        MonthlyRecordView()
                    default:
                        EmptyView()
                    }
                }
                .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 0.98)), removal: .opacity))
                .animation(.easeInOut(duration: 0.4), value: currentMainTab)
                
                // ================= 3. 顶层：全局悬浮置顶导航栏 =================
                globalTopNavBar
                
                // ================= 4. ✨ 终极详情页覆盖层 (Hero Animation) =================
                if let book = selectedBook {
                    BookDetailView(book: book, namespace: namespace, activeCoverID: $activeCoverID, selectedBook: $selectedBook)
                        .zIndex(100) // 确保在最最最顶层
                        .transition(.asymmetric(insertion: .identity, removal: .offset(x: 0.001, y: 0)))
                }
                
                // ================= 5. ✨ 主页：录入新书弹窗引擎 =================
                if showAddModal {
                    // 👉 使用新的绝对居中全屏容器
                    ZStack(alignment: .center) {
                        Color.black.opacity(isDarkMode ? 0.5 : 0.2)
                            .ignoresSafeArea()
                            .onTapGesture {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) { showAddModal = false }
                            }
                            .transition(.opacity)
                            .zIndex(1)
                        
                        BookEditorSheet(isPresented: $showAddModal, bookToEdit: nil)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.9).combined(with: .opacity),
                                removal: .scale(scale: 0.9).combined(with: .opacity)
                            ))
                            .zIndex(2)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // ✨ 撑满全屏，无视外层的 alignment: .top
                    .zIndex(101)
                }
            }
            .navigationTitle("")
            .toolbarBackground(.hidden, for: .windowToolbar)
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .animation(.spring(response: 0.4, dampingFraction: 0.75), value: showAddModal)
        }
        .frame(width: 1400, height: 1000)
    }
    
    // MARK: - 拆分：置顶悬浮导航条

    private var globalTopNavBar: some View {
        ZStack {
            HStack(spacing: 0) {
                ForEach(mainTabs, id: \.0) { tab in
                    let title = tab.0
                    let icon = tab.1
                    let isActive = currentMainTab == title
                    
                    let activeTextColor = isDarkMode ? Color.white : Color.twSlate900
                    let inactiveTextColor = isDarkMode ? Color.twSlate400 : Color.twSlate500
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.6, blendDuration: 0.2)) {
                            currentMainTab = title
                        }
                    }) {
                        ZStack {
                            if isActive {
                                Capsule()
                                    .fill(isDarkMode ? Color.white.opacity(0.15) : Color.black.opacity(0.08))
                                    .matchedGeometryEffect(id: "main-nav-tab", in: mainTabNamespace)
                            }
                            HStack(spacing: 6) {
                                Image(systemName: icon)
                                    .font(.system(size: 15, weight: isActive ? .bold : .medium))
                                    .scaleEffect(isActive ? 1.05 : 1.0)
                                Text(title)
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .foregroundColor(isActive ? activeTextColor : inactiveTextColor)
                            .shadow(color: .black.opacity(isActive && isDarkMode ? 0.3 : 0), radius: 2, y: 1)
                        }
                        .frame(height: 44)
                        .frame(maxWidth: .infinity)
                        .contentShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(6)
            .frame(width: 580)
            .liquidGlass(cornerRadius: 100, isDark: isDarkMode)
            
            HStack(alignment: .center) {
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { isDarkMode.toggle() }
                }) {
                    Image(systemName: isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(isDarkMode ? .twSky400 : .orange)
                        .frame(width: 50, height: 50)
                        .liquidGlass(cornerRadius: 25, isDark: isDarkMode)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                HomeAddBookButton {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { showAddModal = true }
                }
            }
        }
        .padding(.horizontal, pagePadding)
        .padding(.top, 20)
        .padding(.bottom, 24)
    }
    
    // MARK: - 拆分：原版阅读主页滚动内容

    private var homeScrollContent: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                HeaderView().padding(.bottom, 20)
                
                VStack(spacing: sectionSpacing) {
                    HStack(alignment: .top, spacing: widgetSpacing) {
                        CurrentReadingWidget(
                            heroBook: readingBooks.first,
                            namespace: namespace,
                            selectedBook: $selectedBook,
                            activeCoverID: $activeCoverID,
                            readingCount: readingBooks.count
                        )
                        .frame(maxWidth: .infinity, alignment: .top)
                        
                        DashboardWidget()
                            .frame(maxWidth: .infinity, alignment: .top)
                    }
                    .padding(.bottom, sectionSpacing)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, pagePadding)
            .padding(.top, 120)
        }
        .ignoresSafeArea(edges: .top)
    }
}

#Preview("Home View") {
    ContentView()
        .modelContainer(PreviewData.shared)
}
