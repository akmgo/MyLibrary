import SwiftData
import SwiftUI

struct ArchiveGalleryView: View {
    let books: [Book]
    let namespace: Namespace.ID
    @Binding var selectedBook: Book?
    @Binding var activeCoverID: String
    
    @Environment(\.colorScheme) var colorScheme
    @State private var activeTab: String = "ALL"
    @State private var displayBooks: [Book] = []
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
        .mask(
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .clear, location: 0.02),
                    .init(color: .black, location: 0.12),
                    .init(color: .black, location: 1.0)
                ],
                startPoint: .top, endPoint: .bottom
            )
        )
        .onAppear { updateDisplayBooks(animate: true) }
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
                            Button(action: {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) { activeTab = tab.0 }
                                updateDisplayBooks(animate: true)
                            }) {
                                ZStack {
                                    if isActive {
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(isDark ? Color.twSlate700 : .white)
                                            .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                                            .matchedGeometryEffect(id: "gallery-tab", in: tabNamespace)
                                    }
                                    Text(tab.1).font(.system(size: 13, weight: .bold))
                                        .foregroundColor(isActive ? (isDark ? .white : .twSlate800) : (isDark ? .twSlate400 : .twSlate500))
                                }
                                .frame(height: 32).frame(maxWidth: .infinity)
                            }.buttonStyle(.plain)
                        }
                    }
                    .padding(4).frame(width: 200)
                    .background(isDark ? Color.twSlate800.opacity(0.4) : Color.twSlate200.opacity(0.4)).background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(isDark ? Color.twSlate700.opacity(0.3) : Color.white.opacity(0.5), lineWidth: 1))
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
