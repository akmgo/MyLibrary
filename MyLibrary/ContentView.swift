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
    
    let mainTabs = ["阅读主页", "全景画廊", "年度轨迹", "月度记录"]
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // ================= 1. 绝对底层：全局统一静止背景 =================
                ambientBackground
                
                // ================= 2. 透明内容层：动态路由 =================
                Group {
                    switch currentMainTab {
                    case "阅读主页":
                        homeScrollContent
                    case "全景画廊":
                        ArchiveGalleryView(books: allBooks, namespace: namespace, selectedBook: $selectedBook, activeCoverID: $activeCoverID)
                    case "年度轨迹":
                        YearlyTimelineView(books: allBooks, namespace: namespace, selectedBook: $selectedBook, activeCoverID: $activeCoverID)
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
                .transition(.asymmetric(insertion: .opacity.combined(with: .scale(scale: 0.98)), removal: .opacity))
                .animation(.easeInOut(duration: 0.4), value: currentMainTab)
                
                // ================= 3. 顶层：全局悬浮置顶导航栏 =================
                globalTopNavBar
                
                // ================= 4. ✨ 终极详情页覆盖层 (Hero Animation) =================
                if let book = selectedBook {
                    BookDetailView(book: book, namespace: namespace, activeCoverID: $activeCoverID, selectedBook: $selectedBook)
                        .zIndex(100) // 确保在最最最顶层
                        // ✨ 神级 Hack：利用 0.001 像素的极微小位移，迫使系统在退场时保留详情页 0.6 秒寿命，给封面飞回争取时间！
                        .transition(.asymmetric(insertion: .identity, removal: .offset(x: 0.001, y: 0)))
                }
            }
            .navigationTitle("")
            .toolbarBackground(.hidden, for: .windowToolbar)
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .sheet(isPresented: $showAddModal) {
                BookEditorSheet()
            }
        }
        .frame(width: 1400, height: 1000)
    }
    
    // MARK: - 拆分：四象限交织光晕引擎

    private var ambientBackground: some View {
        GeometryReader { geo in
            ZStack {
                (isDarkMode ? Color.twSlate950 : Color.twSlate50).ignoresSafeArea()
                Circle()
                    .fill(Color.twSky500.opacity(isDarkMode ? 0.25 : 0.18))
                    .frame(width: geo.size.width * 0.7, height: geo.size.width * 0.7)
                    .blur(radius: 130)
                    .offset(x: -geo.size.width * 0.2, y: -geo.size.height * 0.15)
                Circle()
                    .fill(Color.twPurple600.opacity(isDarkMode ? 0.25 : 0.15))
                    .frame(width: geo.size.width * 0.7, height: geo.size.width * 0.7)
                    .blur(radius: 130)
                    .offset(x: geo.size.width * 0.5, y: geo.size.height * 0.4)
                Circle()
                    .fill(Color.twIndigo500.opacity(isDarkMode ? 0.20 : 0.12))
                    .frame(width: geo.size.width * 0.45, height: geo.size.width * 0.45)
                    .blur(radius: 100)
                    .offset(x: geo.size.width * 0.6, y: -geo.size.height * 0.1)
                Circle()
                    .fill(Color.twFuchsia500.opacity(isDarkMode ? 0.18 : 0.10))
                    .frame(width: geo.size.width * 0.45, height: geo.size.width * 0.45)
                    .blur(radius: 100)
                    .offset(x: -geo.size.width * 0.1, y: geo.size.height * 0.6)
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
    
    // MARK: - 拆分：置顶悬浮导航条

    private var globalTopNavBar: some View {
        ZStack {
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
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(isDarkMode ? Color.twSlate700.opacity(0.3) : Color.white.opacity(0.5), lineWidth: 1)
            )
            
            HStack(alignment: .center) {
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
                
                // 👉 右侧：录入新书按钮 (替换为动画组件)
                HomeAddBookButton {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showAddModal = true
                    }
                }
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
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea(edges: .top)
        )
    }
    
    // MARK: - 拆分：原版阅读主页滚动内容

    private var homeScrollContent: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                HeaderView().padding(.bottom, 20)
                
                VStack(spacing: sectionSpacing) {
                    HStack(alignment: .top, spacing: widgetSpacing) {
                        // ✨ 传入 activeCoverID 绑定
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
                    
                    if !allBooks.isEmpty {
                        // ✨ 暂时不联动 3D 轮播模块，去除参数调用
                        CarouselWidget(books: allBooks)
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
    ContentView()
        .modelContainer(PreviewData.shared)
}
