import SwiftData
import SwiftUI

struct YearlyTimelineView: View {
    let books: [Book]
    let namespace: Namespace.ID
    @Binding var selectedBook: Book?
    @Binding var activeCoverID: String
    
    @Environment(\.colorScheme) var colorScheme
    let topSpacing: CGFloat = 170
    
    private var currentYearNum: Int { Calendar.current.component(.year, from: Date()) }
    
    private var yearlyBooks: [Book] {
        books.filter { book in
            guard book.status == "FINISHED", let endDate = book.endTime else { return false }
            return Calendar.current.component(.year, from: endDate) == currentYearNum
        }.sorted { ($0.endTime ?? Date.distantPast) > ($1.endTime ?? Date.distantPast) }
    }
    
    var body: some View {
        let isDark = colorScheme == .dark
        
        ScrollView {
            VStack(spacing: 0) {
                if yearlyBooks.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "calendar.badge.exclamationmark").font(.system(size: 64)).foregroundColor(isDark ? .twSlate600 : .twSlate400).opacity(0.5)
                        Text("今年还没有读完的书籍，继续努力哦！").font(.system(size: 18, weight: .bold)).foregroundColor(isDark ? .twSlate500 : .twSlate400)
                    }.frame(maxWidth: .infinity, minHeight: 300)
                } else {
                    ZStack(alignment: .top) {
                        LinearGradient(colors: [Color.twIndigo500.opacity(0), Color.twIndigo500.opacity(0.4), Color.twIndigo500.opacity(0)], startPoint: .top, endPoint: .bottom)
                            .frame(width: 3).cornerRadius(1.5)
                        
                        VStack(spacing: 80) {
                            ForEach(Array(yearlyBooks.enumerated()), id: \.element.id) { index, book in
                                TimelineRowView(
                                    book: book, isLeft: index % 2 == 0,
                                    namespace: namespace, selectedBook: $selectedBook, activeCoverID: $activeCoverID
                                )
                                .zIndex(selectedBook?.id == book.id ? 999 : 0)
                            }
                        }.padding(.vertical, 40)
                    }
                }
            }
            .padding(.horizontal, 40).padding(.top, topSpacing).padding(.bottom, 60)
        }
    }
}

// MARK: - 独立私有时间线行组件
private struct TimelineRowView: View {
    let book: Book; let isLeft: Bool
    let namespace: Namespace.ID
    @Binding var selectedBook: Book?; @Binding var activeCoverID: String
    @Environment(\.colorScheme) var colorScheme
    @State private var isHovered = false
    
    private var dateStr: String {
        guard let date = book.endTime else { return "未知" }
        let formatter = DateFormatter(); formatter.dateFormat = "M月d日"; return formatter.string(from: date)
    }
    
    var body: some View {
        let isDark = colorScheme == .dark
        HStack(spacing: 0) {
            Group {
                if isLeft {
                    TimelineCardView(book: book, isCardOnLeft: true, isDark: isDark, isHovered: $isHovered, namespace: namespace, selectedBook: $selectedBook, activeCoverID: $activeCoverID).padding(.trailing, 60)
                } else {
                    TimelineDateView(dateStr: dateStr, rating: book.rating, isLeft: true, isDark: isDark, isHovered: isHovered).padding(.trailing, 60)
                }
            }.frame(maxWidth: .infinity, alignment: .trailing)
            
            ZStack {
                Circle().fill(isDark ? Color.twSlate900 : .white).frame(width: 16, height: 16).overlay(Circle().stroke(Color.twIndigo500, lineWidth: 4)).shadow(color: Color.twIndigo500.opacity(isHovered ? 0.8 : 0.0), radius: isHovered ? 12 : 0).scaleEffect(isHovered ? 1.5 : 1.0)
            }.frame(width: 20).zIndex(10)
            
            Group {
                if isLeft {
                    TimelineDateView(dateStr: dateStr, rating: book.rating, isLeft: false, isDark: isDark, isHovered: isHovered).padding(.leading, 60)
                } else {
                    TimelineCardView(book: book, isCardOnLeft: false, isDark: isDark, isHovered: $isHovered, namespace: namespace, selectedBook: $selectedBook, activeCoverID: $activeCoverID).padding(.leading, 60)
                }
            }.frame(maxWidth: .infinity, alignment: .leading)
        }.zIndex(selectedBook?.id == book.id ? 999 : 0)
    }
}

private struct TimelineDateView: View {
    let dateStr: String; let rating: Int; let isLeft: Bool; let isDark: Bool; let isHovered: Bool
    var body: some View {
        VStack(alignment: isLeft ? .trailing : .leading, spacing: 8) {
            Text(dateStr).font(.system(size: 28, weight: .bold, design: .rounded)).tracking(2).foregroundColor(isHovered ? .twIndigo500 : (isDark ? .twSlate500 : .twSlate400)).opacity(isHovered ? 1.0 : 0.6)
            if rating >= 4 {
                HStack(spacing: 4) { Text("🔥 强推").font(.system(size: 13, weight: .bold)) }.foregroundColor(.orange).padding(.horizontal, 12).padding(.vertical, 4).background(Color.orange.opacity(0.1)).clipShape(Capsule())
            }
        }.offset(y: isHovered ? -4 : 0)
    }
}

private struct TimelineCardView: View {
    let book: Book; let isCardOnLeft: Bool; let isDark: Bool; @Binding var isHovered: Bool
    let namespace: Namespace.ID; @Binding var selectedBook: Book?; @Binding var activeCoverID: String
    
    var body: some View {
        HStack(spacing: 24) {
            if isCardOnLeft { textSection; coverSection } else { coverSection; textSection }
        }
        .padding(24).frame(width: 420)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous).fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 24, style: .continuous).fill(isDark ? Color.twSlate900.opacity(0.6) : Color.white.opacity(0.7))
                GeometryReader { geo in
                    ZStack {
                        Circle().fill(Color.twIndigo500).frame(width: 150, height: 150).blur(radius: 40).scaleEffect(isHovered ? 2.5 : 0.5).opacity(isHovered ? (isDark ? 0.35 : 0.2) : 0.0)
                        Image(systemName: "touchid").font(.system(size: 180, weight: .ultraLight)).foregroundColor(isDark ? Color.white.opacity(0.04) : Color.black.opacity(0.03)).scaleEffect(isHovered ? 1.08 : 1.0)
                    }.rotationEffect(.degrees(15)).position(x: isCardOnLeft ? 0 : geo.size.width, y: geo.size.height)
                    
                    ZStack {
                        Circle().fill(Color.twIndigo500).frame(width: 80, height: 80).blur(radius: 30).scaleEffect(isHovered ? 2.0 : 0.5).opacity(isHovered ? (isDark ? 0.25 : 0.15) : 0.0)
                        Image(systemName: "quote.opening").font(.system(size: 60, weight: .bold)).foregroundColor(isDark ? Color.twIndigo500.opacity(0.15) : Color.twIndigo500.opacity(0.08)).scaleEffect(isHovered ? 1.15 : 1.0)
                    }.position(x: isCardOnLeft ? 40 : geo.size.width - 40, y: 40)
                }.clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(isHovered ? Color.twIndigo500.opacity(0.4) : (isDark ? Color.white.opacity(0.05) : Color.white.opacity(0.6)), lineWidth: 1))
        .shadow(color: Color.black.opacity(isDark ? (isHovered ? 0.4 : 0.2) : (isHovered ? 0.15 : 0.05)), radius: isHovered ? 30 : 15, y: isHovered ? 15 : 8)
        .offset(y: isHovered ? -8 : 0)
        .contentShape(Rectangle())
        .onHover { h in withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) { isHovered = h } }
        .onTapGesture { activeCoverID = "timeline-\(book.id)"; withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { selectedBook = book } }
        .pointingHand()
        .zIndex(selectedBook?.id == book.id ? 999 : 0)
    }
    
    private var coverSection: some View {
        ZStack {
            if selectedBook?.id != book.id {
                Color.clear.overlay(LocalCoverView(coverData: book.coverData, fallbackTitle: book.title))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(isDark ? Color.white.opacity(0.1) : Color.black.opacity(0.05), lineWidth: 1))
                    .matchedGeometryEffect(id: "timeline-\(book.id)", in: namespace)
                    .frame(width: 110, height: 165)
            } else {
                Color.clear.frame(width: 110, height: 165)
            }
        }
        .shadow(color: Color.twIndigo500.opacity(selectedBook?.id == book.id ? 0 : (isHovered ? 0.3 : 0.0)), radius: isHovered ? 15 : 0, y: isHovered ? 10 : 0)
        .scaleEffect(isHovered && selectedBook?.id != book.id ? 1.05 : 1.0)
        .zIndex(selectedBook?.id == book.id ? 999 : 0)
    }
    
    private var textSection: some View {
        VStack(alignment: isCardOnLeft ? .trailing : .leading, spacing: 8) {
            Text(book.title).font(.system(size: 20, weight: .bold)).foregroundColor(isHovered ? .twIndigo500 : (isDark ? .white : .twSlate800)).lineLimit(2).multilineTextAlignment(isCardOnLeft ? .trailing : .leading)
            Text(book.author).font(.system(size: 14, weight: .bold)).foregroundColor(isDark ? .twSlate400 : .twSlate500).lineLimit(1).multilineTextAlignment(isCardOnLeft ? .trailing : .leading)
            if book.rating > 0 {
                HStack(spacing: 4) {
                    ForEach(1 ... 5, id: \.self) { i in
                        Image(systemName: "star.fill").font(.system(size: 12)).foregroundColor(i <= book.rating ? .yellow : (isDark ? .twSlate700 : .twSlate200)).shadow(color: i <= book.rating ? Color.yellow.opacity(0.4) : .clear, radius: 4)
                    }
                }.padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, alignment: isCardOnLeft ? .trailing : .leading).zIndex(0)
    }
}

#Preview("Light Mode - Yearly Timeline") {
    @Previewable @Namespace var ns
    @Previewable @State var selectedBook: Book? = nil
    @Previewable @State var activeCoverID = ""
    YearlyTimelineView(books: PreviewData.allMockBooks, namespace: ns, selectedBook: $selectedBook, activeCoverID: $activeCoverID)
        .frame(width: 1200, height: 900).preferredColorScheme(.light).modelContainer(PreviewData.shared)
}

#Preview("Dark Mode - Yearly Timeline") {
    @Previewable @Namespace var ns
    @Previewable @State var selectedBook: Book? = nil
    @Previewable @State var activeCoverID = ""
    YearlyTimelineView(books: PreviewData.allMockBooks, namespace: ns, selectedBook: $selectedBook, activeCoverID: $activeCoverID)
        .frame(width: 1200, height: 900).preferredColorScheme(.dark).modelContainer(PreviewData.shared)
}
