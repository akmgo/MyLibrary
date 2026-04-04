import SwiftData
import SwiftUI

// MARK: - ✨ 全局画廊布局配置
public enum GalleryConfig {
    /// 封面真实宽度
    public static let coverWidth: CGFloat = 200
    /// 封面真实高度 (严格保持 2:3 比例)
    public static let coverHeight: CGFloat = 300
    /// 卡片之间的水平间距
    public static let horizontalSpacing: CGFloat = 32
    /// 上下行之间的垂直间距
    public static let verticalSpacing: CGFloat = 40
}

struct ArchiveGalleryView: View {
    @Query var books: [Book]
    let namespace: Namespace.ID
    @Binding var selectedBook: Book?
    @Binding var activeCoverID: String
    
    @Environment(\.colorScheme) var colorScheme
    @State private var activeTab: String = "ALL"
    @State private var displayBooks: [Book] = []
    @State private var hoveredTab: String? = nil
    @Namespace private var tabNamespace
    
    let tabs: [(String, String)] = [("UNREAD", "待读"), ("ALL", "全部"), ("FINISHED", "已读")]
    let topSpacing: CGFloat = 170
    
    var body: some View {
        ScrollView {
            gridView
                .padding(.horizontal, 40)
                .padding(.top, topSpacing)
                .padding(.bottom, 60)
        }
        .ignoresSafeArea(edges: .top)
        .onAppear { updateDisplayBooks(animate: false) }
        .onChange(of: books) { _, _ in updateDisplayBooks(animate: true) }
    }
    
    @ViewBuilder
    private var gridView: some View {
        let isDark = colorScheme == .dark
        
        if displayBooks.isEmpty {
            VStack {
                Text("暂无对应的书籍记录").font(.system(size: 18, weight: .bold)).foregroundColor(.twSlate400).tracking(4)
            }
            .frame(maxWidth: .infinity, minHeight: 300)
        } else {
            // ✨ 直接使用封面的宽度作为网格列宽
            let columns = [GridItem(.adaptive(minimum: GalleryConfig.coverWidth, maximum: GalleryConfig.coverWidth + 20), spacing: GalleryConfig.horizontalSpacing)]
            
            VStack(alignment: .leading, spacing: 32) {
                // ======= 顶部控制栏 =======
                HStack(alignment: .center) {
                    HStack(spacing: 8) {
                        Circle().fill(Color.twSky500).frame(width: 6, height: 6).shadow(color: Color.twSky500.opacity(0.8), radius: 4)
                        Text("共收录 \(displayBooks.count) 卷").font(.system(size: 13, weight: .bold))
                    }
                    .foregroundColor(isDark ? .twSlate200 : .twSlate700)
                    .padding(.horizontal, 16).padding(.vertical, 8)
                    .background(isDark ? Color.twSlate800.opacity(0.5) : Color.white.opacity(0.8)).background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(isDark ? Color.white.opacity(0.1) : Color.twSlate200.opacity(0.8), lineWidth: 1))
                    .shadow(color: Color.black.opacity(isDark ? 0.2 : 0.05), radius: 8, y: 4)
                    
                    Spacer()
                    
                    HStack(spacing: 0) {
                        ForEach(tabs, id: \.0) { tab in
                            let isActive = activeTab == tab.0
                            let isHovered = hoveredTab == tab.0
                            
                            let activeColor = isDark ? Color.white : Color.twSlate900
                            let inactiveColor = isDark ? Color.twSlate400 : Color.twSlate500
                            let hoverColor = isDark ? Color.white.opacity(0.85) : Color.twSlate700
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) { activeTab = tab.0 }
                                updateDisplayBooks(animate: true)
                            }) {
                                ZStack {
                                    if isActive {
                                        RoundedRectangle(cornerRadius: AppleRadius.small, style: .continuous)
                                            .fill(isDark ? Color.white.opacity(0.15) : Color.black.opacity(0.08))
                                            .matchedGeometryEffect(id: "gallery-tab", in: tabNamespace)
                                    }
                                    Text(tab.1).font(.system(size: 13, weight: .bold))
                                        .foregroundColor(isActive ? activeColor : (isHovered ? hoverColor : inactiveColor))
                                }
                                .frame(height: 32).frame(maxWidth: .infinity)
                                .scaleEffect((isHovered || isActive) ? 1.05 : 1.0)
                            }
                            .buttonStyle(.plain).pointingHand()
                            .onHover { h in
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { hoveredTab = h ? tab.0 : nil }
                            }
                        }
                    }
                    .padding(4).frame(width: 200)
                    .liquidGlass(radius: AppleRadius.regular, isDark: isDark)
                }
                .padding(.horizontal, 10)
                
                // ======= 书籍网格 =======
                LazyVGrid(columns: columns, spacing: GalleryConfig.verticalSpacing) {
                    ForEach(displayBooks, id: \.id) { book in
                        GalleryBookCardView(book: book,
                                            showStatus: activeTab == "ALL",
                                            isFinishedTab: activeTab == "FINISHED",
                                            namespace: namespace,
                                            activeCoverID: activeCoverID,
                                            selectedBook: selectedBook)
                            .onTapGesture {
                                activeCoverID = "gallery-\(book.id)"
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { selectedBook = book }
                            }
                            .zIndex(selectedBook?.id == book.id ? 999 : 0)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.8).combined(with: .opacity).combined(with: .offset(y: 40)),
                                removal: .scale(scale: 0.8).combined(with: .opacity)
                            ))
                    }
                }
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: displayBooks)
            }
            // ✨ 去掉了大底座，还原干爽视觉
        }
    }
    
    private func updateDisplayBooks(animate: Bool = false) {
        let updateAction = {
            var filtered = books
            if activeTab != "ALL" { filtered = books.filter { $0.status == activeTab } }
            if activeTab == "FINISHED" {
                displayBooks = filtered.sorted { ($0.endTime ?? Date.distantPast) > ($1.endTime ?? Date.distantPast) }
            } else {
                displayBooks = filtered.shuffled()
            }
        }
        if animate { withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { updateAction() } } else { updateAction() }
    }
}
