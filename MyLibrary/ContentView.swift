import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    @Query(filter: #Predicate<Book> { $0.status == "READING" }) var readingBooks: [Book]
    @Query var allBooks: [Book]
    
    let pagePadding: CGFloat = 30
    let widgetSpacing: CGFloat = 60
    let sectionSpacing: CGFloat = 60
    
    @Namespace private var namespace
    @State private var selectedBook: Book? = nil
    @State private var activeCoverID: String = ""
    @State private var showAddModal = false
    
    @State private var currentMainTab: String = "阅读主页"
    @Namespace private var mainTabNamespace
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // 1. 绝对底层背景
                FluidBackgroundView(isDark: isDarkMode)
                
                // 2. 内容路由引擎
                Group {
                    switch currentMainTab {
                    case "阅读主页":
                        homeScrollContent
                    case "全景画廊":
                        ArchiveGalleryView(books: allBooks, namespace: namespace, selectedBook: $selectedBook, activeCoverID: $activeCoverID)
                    case "3D漫游":
                        // ✨ 单独抽离的 3D 画廊模块
                        ZStack {
                            if allBooks.isEmpty {
                                Text("暂无书籍，去主页录入第一本吧").foregroundColor(.twSlate500)
                            } else {
                                CarouselWidget(books: allBooks)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                        .padding(.top, 100) // 避开导航栏
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
                
                // 3. 抽离后的悬浮导航栏
                TopNavigationBarView(
                    currentMainTab: $currentMainTab,
                    showAddModal: $showAddModal,
                    isDarkMode: $isDarkMode,
                    mainTabNamespace: mainTabNamespace
                )
                
                // 4. 详情页悬浮罩
                if let book = selectedBook {
                    BookDetailView(book: book, namespace: namespace, activeCoverID: $activeCoverID, selectedBook: $selectedBook)
                        .zIndex(100)
                        .transition(.asymmetric(insertion: .identity, removal: .offset(x: 0.001, y: 0)))
                }
                
                // 5. 录入书籍弹窗
                if showAddModal {
                    ZStack(alignment: .center) {
                        Color.black.opacity(isDarkMode ? 0.5 : 0.2)
                            .ignoresSafeArea()
                            .onTapGesture { withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) { showAddModal = false } }
                            .transition(.opacity)
                            .zIndex(1)
                        
                        BookEditorSheet(isPresented: $showAddModal, bookToEdit: nil)
                            .transition(.asymmetric(insertion: .scale(scale: 0.9).combined(with: .opacity), removal: .scale(scale: 0.9).combined(with: .opacity)))
                            .zIndex(2)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .zIndex(101)
                }
            }
            .navigationTitle("")
            #if os(macOS)
            .toolbarBackground(.hidden, for: .windowToolbar)
            #else
            .toolbarBackground(.hidden, for: .navigationBar)
            #endif
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .animation(.spring(response: 0.4, dampingFraction: 0.75), value: showAddModal)
        }
    }
    
    // 主页核心内容 (剔除了 CarouselWidget)
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
