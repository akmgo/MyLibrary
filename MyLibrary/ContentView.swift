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
    
    @State private var currentMainTab: String = "阅读主页"
    @Namespace private var mainTabNamespace
    
    let mainTabs = ["阅读主页", "全景画廊", "年度轨迹", "月度记录"]
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // ================= 1. 绝对底层：全局统一静止背景 =================
                // 把它放在 Group 外面，切换 Tab 时它绝对不会闪烁或重绘！
                ambientBackground
                
                // ================= 2. 透明内容层：动态路由 =================
                Group {
                    switch currentMainTab {
                    case "阅读主页":
                        homeScrollContent
                    case "全景画廊":
                        ArchiveGalleryView(books: allBooks, selectedBook: $selectedBook)
                    case "年度轨迹":
                        YearlyTimelineView(books: allBooks)
                    case "月度记录":
                        VStack {
                            Spacer()
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 64))
                                .foregroundColor(isDarkMode ? .twSlate600 : .twSlate400)
                                .padding(.bottom, 16)
                            Text("月度足迹模块开发中...")
                                .font(.title2).bold()
                                .foregroundColor(isDarkMode ? .twSlate500 : .twSlate400)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    default:
                        EmptyView()
                    }
                }
                // 内容切换时的淡入淡出动画
                .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 0.98)), removal: .opacity))
                .animation(.easeInOut(duration: 0.4), value: currentMainTab)
                
                // ================= 3. 顶层：全局悬浮置顶导航栏 =================
                globalTopNavBar
            }
            .navigationTitle("")
            .toolbarBackground(.hidden, for: .windowToolbar)
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
    
    // MARK: - ✨ 拆分：四象限交织光晕引擎

    private var ambientBackground: some View {
        GeometryReader { geo in
            ZStack {
                (isDarkMode ? Color.twSlate950 : Color.twSlate50)
                    .ignoresSafeArea()

                // 左上：天蓝
                Circle()
                    .fill(Color.twSky500.opacity(isDarkMode ? 0.25 : 0.18))
                    .frame(width: geo.size.width * 0.7, height: geo.size.width * 0.7)
                    .blur(radius: 130)
                    .offset(x: -geo.size.width * 0.2, y: -geo.size.height * 0.15)

                // 右下：紫红
                Circle()
                    .fill(Color.twPurple600.opacity(isDarkMode ? 0.25 : 0.15))
                    .frame(width: geo.size.width * 0.7, height: geo.size.width * 0.7)
                    .blur(radius: 130)
                    .offset(x: geo.size.width * 0.5, y: geo.size.height * 0.4)

                // 右上：靛蓝
                Circle()
                    .fill(Color.twIndigo500.opacity(isDarkMode ? 0.20 : 0.12))
                    .frame(width: geo.size.width * 0.45, height: geo.size.width * 0.45)
                    .blur(radius: 100)
                    .offset(x: geo.size.width * 0.6, y: -geo.size.height * 0.1)

                // 左下：品红
                Circle()
                    .fill(Color.twFuchsia500.opacity(isDarkMode ? 0.18 : 0.10))
                    .frame(width: geo.size.width * 0.45, height: geo.size.width * 0.45)
                    .blur(radius: 100)
                    .offset(x: -geo.size.width * 0.1, y: geo.size.height * 0.6)

                // 中心：托底防死黑
                if isDarkMode {
                    Circle()
                        .fill(Color.twIndigo500.opacity(0.12))
                        .frame(width: geo.size.width * 0.5, height: geo.size.width * 0.5)
                        .blur(radius: 150)
                        .position(x: geo.size.width / 2, y: geo.size.height / 2)
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .animation(.easeInOut(duration: 0.7), value: isDarkMode)
    }
    
    // MARK: - 拆分：置顶悬浮导航条 (已修复绝对居中问题)

    private var globalTopNavBar: some View {
        // ✨ 核心修复：使用 ZStack 让中间的导航栏进行绝对居中，不受左右按钮宽度不一致的影响
        ZStack {
            // 👆 正中间：核心四字模块切换窗格 (绝对居中层)
            HStack(spacing: 0) {
                ForEach(mainTabs, id: \.self) { tab in
                    let isActive = currentMainTab == tab
                    let activeTextColor = isDarkMode ? Color.white : Color.twSlate800
                    let inactiveTextColor = isDarkMode ? Color.twSlate400 : Color.twSlate500
                        
                    Button(action: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) { currentMainTab = tab }
                    }) {
                        ZStack {
                            if isActive {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(isDarkMode ? Color.twSlate700 : .white)
                                    .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                                    .matchedGeometryEffect(id: "main-nav-tab", in: mainTabNamespace)
                            }
                            Text(tab)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(isActive ? activeTextColor : inactiveTextColor)
                        }
                        .frame(height: 44)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(6)
            .frame(width: 520)
            .background(isDarkMode ? Color.twSlate800.opacity(0.4) : Color.twSlate200.opacity(0.4))
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(isDarkMode ? Color.twSlate700.opacity(0.3) : Color.white.opacity(0.5), lineWidth: 1))
                
            // 👈 左侧与 👉 右侧 功能键 (悬浮层)
            HStack(alignment: .center) {
                // 左侧：深浅色模式切换
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { isDarkMode.toggle() }
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
                    
                // 右侧：录入新书
                Button(action: { /* 弹窗录入新书 */ }) {
                    Label("录入新书", systemImage: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(LinearGradient(colors: [.indigo, .purple], startPoint: .leading, endPoint: .trailing))
                        .clipShape(Capsule())
                        .shadow(color: .indigo.opacity(0.3), radius: 8, y: 4)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, pagePadding)
        .padding(.top, 20)
        .padding(.bottom, 24)
        .background(
            LinearGradient(
                colors: [
                    isDarkMode ? Color.twSlate950 : Color.twSlate50,
                    (isDarkMode ? Color.twSlate950 : Color.twSlate50).opacity(0.9),
                    (isDarkMode ? Color.twSlate950 : Color.twSlate50).opacity(0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .top)
        )
    }
    
    // MARK: - 拆分：原版阅读主页滚动内容

    private var homeScrollContent: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                HeaderView()
                    .padding(.bottom, 20)
                
                VStack(spacing: sectionSpacing) {
                    HStack(alignment: .top, spacing: widgetSpacing) {
                        CurrentReadingWidget(
                            heroBook: readingBooks.first,
                            namespace: namespace,
                            selectedBook: $selectedBook,
                            readingCount: readingBooks.count
                        )
                        .frame(maxWidth: .infinity, alignment: .top)
                        
                        DashboardWidget()
                            .frame(maxWidth: .infinity, alignment: .top)
                    }
                    .padding(.bottom, sectionSpacing)
                    
                    if !allBooks.isEmpty {
                        CarouselWidget(books: allBooks, namespace: namespace, selectedBook: $selectedBook)
                            .padding(.bottom, 80)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, pagePadding)
            .padding(.top, topSpacing)
        }
    }
}

#Preview("Home View") {
    struct HomePreviewWrapper: View {
        @Namespace var namespace; @State var selectedBook: Book?
        var body: some View {
            ContentView()
        }
    }
    return HomePreviewWrapper().modelContainer(PreviewData.shared).frame(width: 1440, height: 1200)
}
