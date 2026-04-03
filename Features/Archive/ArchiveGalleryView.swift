import SwiftData
import SwiftUI

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
    let horizontalSpacing: CGFloat = 32
    let verticalSpacing: CGFloat = 40
    let topSpacing: CGFloat = 170
    
    var body: some View {
        // ✨ 完全脱去背景代码，只保留透明的 ScrollView
        ScrollView {
            gridView
                .padding(.horizontal, 60)
                .padding(.top, topSpacing)
                .padding(.bottom, 60)
        }
        .ignoresSafeArea(edges: .top)
        .onAppear { updateDisplayBooks(animate: false) }
        // 只有在用户主动点击 Tab 切换分类（比如从“全部”切到“已读”）时，才触发排序动画
        .onChange(of: books) { _, _ in updateDisplayBooks(animate: true) }
    }
    
    @ViewBuilder
    private var gridView: some View {
        let isDark = colorScheme == .dark
        
        if displayBooks.isEmpty {
            VStack {
                Text("暂无对应的书籍记录").font(.system(size: 18, weight: .bold)).foregroundColor(.twSlate400).tracking(4)
            }.frame(maxWidth: .infinity, minHeight: 300)
        } else {
            let columns = [GridItem(.adaptive(minimum: 160, maximum: 240), spacing: horizontalSpacing)]
            
            VStack(alignment: .leading, spacing: 24) {
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
                                    // ✨ 同样去掉了灰底，保持极简
                                    if isActive {
                                        // ✨ 替换为 AppleRadius.small
                                        RoundedRectangle(cornerRadius: AppleRadius.small, style: .continuous)
                                            .fill(isDark ? Color.white.opacity(0.15) : Color.black.opacity(0.08))
                                            .matchedGeometryEffect(id: "gallery-tab", in: tabNamespace)
                                    }
                                                                                        
                                    Text(tab.1).font(.system(size: 13, weight: .bold))
                                        // ✨ 悬浮时字体提亮
                                        .foregroundColor(isActive ? activeColor : (isHovered ? hoverColor : inactiveColor))
                                }
                                .frame(height: 32).frame(maxWidth: .infinity)
                                // ✨ 悬浮时微微跃起放大
                                .scaleEffect((isHovered || isActive) ? 1.05 : 1.0)
                            }
                            .buttonStyle(.plain).pointingHand()
                            .onHover { h in
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { hoveredTab = h ? tab.0 : nil }
                            }
                        }
                    }
                    .padding(4).frame(width: 200)
                    // ✨ 替换为 AppleRadius.regular 及其新参数名
                    .liquidGlass(radius: AppleRadius.regular, isDark: isDark)
                }
                .padding(.horizontal, 10)
                
                LazyVGrid(columns: columns, spacing: verticalSpacing) {
                    ForEach(displayBooks, id: \.id) { book in
                        GalleryBookCardView(book: book,
                                            showStatus: activeTab == "ALL",
                                            isFinishedTab: activeTab == "FINISHED",
                                            namespace: namespace,
                                            activeCoverID: activeCoverID,
                                            selectedBook: selectedBook)
                            .onTapGesture {
                                // ✨ 设置起飞坐标，并包裹在弹簧动画中触发选中
                                activeCoverID = "gallery-\(book.id)"
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    selectedBook = book
                                }
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
