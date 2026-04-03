import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    @Query(filter: #Predicate<Book> { $0.status == "READING" }) var readingBooks: [Book]
    
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
        ZStack(alignment: .top) {
            FluidBackgroundView(isDark: isDarkMode)
            
            Group {
                switch currentMainTab {
                case "阅读主页":
                    homeScrollContent
                case "全景画廊":
                    ArchiveGalleryView(namespace: namespace, selectedBook: $selectedBook, activeCoverID: $activeCoverID)
                case "3D漫游":
                    CarouselWidget()
                        .padding(.top, 100)
                case "年度轨迹":
                    YearlyTimelineView(namespace: namespace, selectedBook: $selectedBook, activeCoverID: $activeCoverID)
                case "月度记录":
                    MonthlyRecordView()
                default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.3), value: currentMainTab)
            
            TopNavigationBarView(currentMainTab: $currentMainTab, showAddModal: $showAddModal, isDarkMode: $isDarkMode, mainTabNamespace: mainTabNamespace)
            
            // ================= ✨ 独立出来的深浅模式“灵动岛”按钮 =================
            VStack {
                HStack {
                    Spacer()
                    ThemeToggleButton(isDarkMode: $isDarkMode)
                }
                Spacer()
            }
            // ✨ 坐标完美对齐左上角的 macOS 原生红绿灯，但是放在右上角
            .padding(.top, 10)
            .padding(.trailing, 10)
            .zIndex(105) // 保证在内容之上，但在弹窗之下
            
            // ================= 详情与弹窗层 =================
            if let book = selectedBook {
                BookDetailView(book: book, namespace: namespace, activeCoverID: $activeCoverID, selectedBook: $selectedBook)
                    .zIndex(200)
                    .transition(.asymmetric(insertion: .identity, removal: .offset(x: 0.001, y: 0)))
            }
            
            if showAddModal {
                ZStack(alignment: .center) {
                    Color.black.opacity(isDarkMode ? 0.5 : 0.2).ignoresSafeArea()
                        .onTapGesture { withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) { showAddModal = false } }.transition(.opacity).zIndex(1)
                    BookEditorSheet(isPresented: $showAddModal, bookToEdit: nil)
                        .transition(.asymmetric(insertion: .scale(scale: 0.9).combined(with: .opacity), removal: .scale(scale: 0.9).combined(with: .opacity))).zIndex(2)
                }.frame(maxWidth: .infinity, maxHeight: .infinity).zIndex(101)
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // ✨ 终极绝杀：强迫整个 App 无视顶部系统安全区，彻底打碎最后一道边界线！
        .ignoresSafeArea(edges: .top)
    }
    
    
    private var homeScrollContent: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                HeaderView().padding(.bottom, 20)
                
                VStack(spacing: sectionSpacing) {
                    HStack(alignment: .top, spacing: widgetSpacing) {
                        CurrentReadingWidget(heroBook: readingBooks.first, namespace: namespace, selectedBook: $selectedBook, activeCoverID: $activeCoverID, readingCount: readingBooks.count)
                            .frame(maxWidth: .infinity, alignment: .top)
                        DashboardWidget().frame(maxWidth: .infinity, alignment: .top)
                    }.padding(.bottom, sectionSpacing)
                }.frame(maxWidth: .infinity)
            }
            .padding(.horizontal, pagePadding)
            .padding(.top, 120) // 留足顶部空间给导航栏
        }
        // 这里不需要再写 ignoresSafeArea，因为外层 ZStack 已经打通了！
    }
}

// MARK: - 专属组件：右上角灵动岛深浅模式按钮
private struct ThemeToggleButton: View {
    @Binding var isDarkMode: Bool
    @State private var isHovered = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { isDarkMode.toggle() }
        }) {
            Image(systemName: isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(isDarkMode ? .twSky400 : .orange)
                .frame(width: 40, height: 40)
                // ✨ 使用你的全局液态圆形玻璃引擎
                .liquidCircleGlass(isHovered: isHovered, isDark: isDarkMode)
        }
        .buttonStyle(.plain)
        .pointingHand()
        .onHover { h in withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) { isHovered = h } }
    }
}
