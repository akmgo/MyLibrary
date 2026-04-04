internal import Combine
import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    /// 获取当前在读的书籍
    @Query(filter: #Predicate<Book> { $0.status == "READING" }) var readingBooks: [Book]
    
    let pagePadding: CGFloat = 30
    let widgetSpacing: CGFloat = 40
    let sectionSpacing: CGFloat = 60
    
    @Namespace private var namespace
    @State private var selectedBook: Book? = nil
    @State private var activeCoverID: String = ""
    @State private var showAddModal = false
    
    @State private var currentMainTab: String = "阅读主页"
    @Namespace private var mainTabNamespace
    
    let progressTimer = Timer.publish(every: 60, on: .main, in: .common).autoconnect() // 1分钟查进度
    let excerptTimer = Timer.publish(every: 600, on: .main, in: .common).autoconnect() // 10分钟查摘录
    
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
                    CarouselWidget().padding(.top, 100)
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
            
            // ================= ✨ 恢复纯净的深浅模式“灵动岛” =================
            VStack {
                HStack {
                    Spacer()
                    ThemeToggleButton(isDarkMode: $isDarkMode)
                }
                Spacer()
            }
            .padding(.top, 10)
            .padding(.trailing, 10)
            .zIndex(105)
            
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
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                        .transition(.asymmetric(insertion: .scale(scale: 0.9).combined(with: .opacity), removal: .scale(scale: 0.9).combined(with: .opacity))).zIndex(2)
                }.frame(maxWidth: .infinity, maxHeight: .infinity).zIndex(101)
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(edges: .top)
        // ✨ 2. 程序启动/视图出现时，两者都立刻执行一次
        .onAppear {
            syncProgressAndRecord()
            syncExcerpts()
        }
        // ✨ 3. 每 1 分钟执行一次进度同步
        .onReceive(progressTimer) { _ in
            syncProgressAndRecord()
        }
        // ✨ 4. 每 10 分钟执行一次摘录同步
        .onReceive(excerptTimer) { _ in
            syncExcerpts()
        }
    }
    
    // MARK: - ✨ 高频任务：1分钟同步进度与打卡

    private func syncProgressAndRecord() {
        guard let currentBook = readingBooks.first else { return }
        // print("⏱️ [1分钟轮询] 检查进度...")
            
        if let appleProgress = AppleBooksDBUtils.fetchBookProgress(byTitle: currentBook.title) {
            if appleProgress != currentBook.progress {
                print("📈 [进度同步] 发现进度更新: \(currentBook.progress)% -> \(appleProgress)%")
                    
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    currentBook.progress = appleProgress
                }
                    
                let calendar = Calendar.current
                let today = calendar.startOfDay(for: Date())
                let alreadyCheckedInToday = currentBook.reading_record?.contains(where: {
                    calendar.startOfDay(for: $0.date) == today
                }) ?? false
                    
                if !alreadyCheckedInToday {
                    let newRecord = ReadingRecord(date: Date(), book: currentBook)
                    modelContext.insert(newRecord)
                    if currentBook.reading_record == nil { currentBook.reading_record = [] }
                    currentBook.reading_record?.append(newRecord)
                    print("🏅 [自动打卡] 已为您自动生成今日阅读记录！")
                }
                try? modelContext.save()
            }
        }
    }
        
    // MARK: - ✨ 低频任务：10分钟同步最新摘录

    private func syncExcerpts() {
        guard let currentBook = readingBooks.first else { return }
        // print("⏳ [10分钟轮询] 检查摘录...")
            
        if let assetId = AppleBooksDBUtils.fetchAssetId(byTitle: currentBook.title) {
            let appleExcerpts = AppleBooksDBUtils.fetchAnnotations(forAssetId: assetId)
            var addedExcerptsCount = 0
            var hasChanges = false
                
            for appleAnn in appleExcerpts {
                // 严格清洗文本
                let cleanText = appleAnn.text
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .trimmingCharacters(in: CharacterSet(charactersIn: "\"“”「」『』'‘’"))
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    
                if cleanText.isEmpty { continue }
                    
                let alreadyExists = currentBook.excerpts?.contains(where: { $0.content == cleanText }) ?? false
                    
                if !alreadyExists {
                    let newExcerpt = Excerpt(content: cleanText, createdAt: appleAnn.creationDate)
                    newExcerpt.book = currentBook
                    modelContext.insert(newExcerpt)
                        
                    if currentBook.excerpts == nil { currentBook.excerpts = [] }
                    currentBook.excerpts?.append(newExcerpt)
                        
                    addedExcerptsCount += 1
                    hasChanges = true
                }
            }
                
            if addedExcerptsCount > 0 {
                print("📝 [摘录同步] 成功为您在读的《\(currentBook.title)》新增了 \(addedExcerptsCount) 条摘录！")
            }
                
            if hasChanges {
                try? modelContext.save()
            }
        }
    }
    
    private var homeScrollContent: some View {
            ScrollView(.vertical, showsIndicators: false) {
                
                VStack(spacing: 24) {
                    
                    // ✨ 图书馆与格言头部
                    HStack {
                        HeaderView()
                        Spacer()
                    }
                    .padding(.bottom, 10)
                    
                    // ================= 第一排：聚焦与当下 (60% / 40%) =================
                    HStack(spacing: 24) {
                        if let heroBook = readingBooks.first {
                            ReadingCard(
                                book: heroBook,
                                progress: Double(heroBook.progress),
                                isDark: isDarkMode,
                                namespace: namespace,
                                selectedBook: $selectedBook,
                                activeCoverID: $activeCoverID
                            )
                            // ✨ 统一高度 220
                            .frame(width: 600, height: 220)
                        } else {
                            VStack {
                                Text("暂无在读焦点").font(.system(size: 14, weight: .bold)).foregroundColor(.twSlate500)
                            }
                            .frame(width: 600, height: 220) // ✨ 统一高度 220
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        }
                        
                        DashboardWidget()
                            .frame(width: 376, height: 220) // ✨ 统一高度 220
                    }
                    
                    // ================= 第二排：灵魂与数据 (40% / 60%) =================
                    HStack(spacing: 24) {
                        MomentumChartCard()
                            .frame(width: 376, height: 220) // ✨ 统一高度 220
                        
                        ResonanceWaveChart()
                            .frame(width: 600, height: 220) // ✨ 统一高度 220
                    }
                    
                    // ================= 第三排：行动与足迹 (50% / 50%) =================
                    HStack(spacing: 24) {
                        QueueBookshelfChart()
                            .frame(width: 488, height: 220) // ✨ 统一高度 220
                        
                        YearlyHeatmapCard()
                            .frame(width: 488, height: 220) // ✨ 统一高度 220
                    }
                    
                    // ================= 第四排：横贯全局的通栏 =================
                    KnowledgeSpectrumCard()
                        .frame(width: 1000, height: 160) // ✨ 统一高度 220 (原为 160，现在拉高，内部会自动垂直居中)
                    
                }
                .frame(width: 1000) // 锁死内容区总宽度
                .frame(maxWidth: .infinity) // 让它在全屏居中
                .padding(.bottom, sectionSpacing)
                .padding(.top, 100)
            }
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
                .liquidCircleGlass(isHovered: isHovered, isDark: isDarkMode)
        }
        .buttonStyle(.plain)
        .pointingHand()
        .onHover { h in withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) { isHovered = h } }
    }
}
