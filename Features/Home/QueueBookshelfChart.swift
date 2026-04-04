import SwiftUI
import SwiftData
import Charts

struct QueueBookshelfChart: View {
    @Environment(\.colorScheme) var colorScheme
    @Query(filter: #Predicate<Book> { $0.isWantToRead == true }) var wantToReadBooks: [Book]
    
    @State private var showBars = false
    @State private var isHovered = false
    
    struct ChartItem: Identifiable { let id = UUID(); let index: Int; let book: Book }
    
    var body: some View {
        let isDark = colorScheme == .dark
        let displayBooks = Array(wantToReadBooks.prefix(3))
        
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("想读焦点").font(.system(size: 18, weight: .bold, design: .rounded)).foregroundColor(isDark ? .white : .twSlate800)
                    Text("WANT TO READ").font(.system(size: 10, weight: .black)).foregroundColor(.twSlate500).tracking(1)
                }
                Spacer()
                Image(systemName: "sparkles.rectangle.stack").foregroundColor(.twOrange500)
            }
            
            if displayBooks.isEmpty {
                HStack { Spacer(); Text("暂无设定的想读焦点").font(.system(size: 14, weight: .bold)).foregroundColor(.twSlate500); Spacer() }.frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                let safeData = displayBooks.enumerated().map { ChartItem(index: $0.offset, book: $0.element) }
                Chart(safeData) { item in
                    let pedestalHeight = Double(80 - (item.index * 20))
                    BarMark(x: .value("ID", item.id.uuidString), y: .value("Height", showBars ? pedestalHeight : 0))
                        .clipShape(Capsule())
                        // ✨ 内部联动：悬浮时光芒变亮
                        .foregroundStyle(LinearGradient(colors: [Color.twOrange500.opacity(isDark ? (isHovered ? 0.5 : 0.3) : 0.15), .clear], startPoint: .top, endPoint: .bottom))
                        .annotation(position: .top, alignment: .center, spacing: 8) {
                            QueueChartBookItem(book: item.book, index: item.index, isDark: isDark, showBars: showBars)
                        }
                }
                .chartXAxis(.hidden).chartYAxis(.hidden).chartYScale(domain: 0...200)
            }
        }
        .padding(24)
        .background(isDark ? Color.twSlate900.opacity(0.6) : Color.white.opacity(0.8)).background(.ultraThinMaterial).clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .onHover { h in withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) { isHovered = h } }
        .onAppear { withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) { showBars = true } }
    }
}
// QueueChartBookItem 保持原样，封面本身的错落浮动保留
private struct QueueChartBookItem: View {
    let book: Book; let index: Int; let isDark: Bool; let showBars: Bool
    @State private var isItemHovered = false
    var body: some View {
        VStack(spacing: 6) {
            LocalCoverView(coverData: book.coverData, fallbackTitle: book.title).frame(width: 56, height: 84).clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous)).shadow(color: .black.opacity(isDark ? 0.3 : 0.1), radius: 5, y: 3)
            Text(book.title).font(.system(size: 10, weight: .bold)).foregroundColor(isDark ? .twSlate300 : .twSlate600).lineLimit(1).frame(width: 60).multilineTextAlignment(.center)
        }
        .scaleEffect(showBars ? 1.0 : 0.0).animation(.spring(response: 0.5, dampingFraction: 0.6).delay(Double(index) * 0.1), value: showBars)
        .offset(y: isItemHovered ? -6 : 0).scaleEffect(isItemHovered ? 1.08 : 1.0).animation(.spring(response: 0.35, dampingFraction: 0.6), value: isItemHovered)
        .onHover { h in isItemHovered = h }.pointingHand()
    }
}
