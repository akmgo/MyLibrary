import SwiftUI
import SwiftData

struct YearlyTimelineView: View {
    let books: [Book]
    @Environment(\.colorScheme) var colorScheme
    
    private var currentYearNum: Int { Calendar.current.component(.year, from: Date()) }
    
    private var yearlyBooks: [Book] {
        books.filter { book in
            guard book.status == "FINISHED", let endDate = book.endTime else { return false }
            return Calendar.current.component(.year, from: endDate) == currentYearNum
        }.sorted { ($0.endTime ?? Date.distantPast) > ($1.endTime ?? Date.distantPast) }
    }
    
    // ✨ 新增：顶部间距控制变量 (调整这个数值就能控制时间线距离导航栏有多远)
    let topSpacing: CGFloat = 170
    
    var body: some View {
        let isDark = colorScheme == .dark
        
        ScrollView {
            VStack(spacing: 0) {
                // 🚨 原有的 "阅读轨迹" 和 "几本书" 的文字 HStack 已经被彻底删除
                
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
                                TimelineRowView(book: book, isLeft: index % 2 == 0)
                            }
                        }.padding(.vertical, 40)
                    }
                }
            }
            .padding(.horizontal, 40)
            // ✨ 将间距控制变量注入在这里
            .padding(.top, topSpacing)
            .padding(.bottom, 60)
        }
    }
}

// MARK: - 独立的时间线单行视图
struct TimelineRowView: View {
    let book: Book
    let isLeft: Bool
    
    @Environment(\.colorScheme) var colorScheme
    @State private var isHovered = false
    
    private var dateStr: String {
        guard let date = book.endTime else { return "未知" }
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        return formatter.string(from: date)
    }
    
    var body: some View {
        let isDark = colorScheme == .dark
        
        HStack(spacing: 0) {
            // ================= 左侧区域 =================
            Group {
                if isLeft {
                    TimelineCardView(book: book, isCardOnLeft: true, isDark: isDark, isHovered: $isHovered)
                        .padding(.trailing, 60)
                } else {
                    TimelineDateView(dateStr: dateStr, rating: book.rating, isLeft: true, isDark: isDark, isHovered: isHovered)
                        .padding(.trailing, 60)
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            
            // ================= 中心锚点 =================
            ZStack {
                Circle()
                    .fill(isDark ? Color.twSlate900 : .white)
                    .frame(width: 16, height: 16)
                    .overlay(Circle().stroke(Color.twIndigo500, lineWidth: 4))
                    .shadow(color: Color.twIndigo500.opacity(isHovered ? 0.8 : 0.0), radius: isHovered ? 12 : 0)
                    .scaleEffect(isHovered ? 1.5 : 1.0)
            }
            .frame(width: 20)
            .zIndex(10)
            
            // ================= 右侧区域 =================
            Group {
                if isLeft {
                    TimelineDateView(dateStr: dateStr, rating: book.rating, isLeft: false, isDark: isDark, isHovered: isHovered)
                        .padding(.leading, 60)
                } else {
                    TimelineCardView(book: book, isCardOnLeft: false, isDark: isDark, isHovered: $isHovered)
                        .padding(.leading, 60)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - 日期显示区
struct TimelineDateView: View {
    let dateStr: String
    let rating: Int
    let isLeft: Bool
    let isDark: Bool
    let isHovered: Bool
    
    var body: some View {
        VStack(alignment: isLeft ? .trailing : .leading, spacing: 8) {
            Text(dateStr)
                // ✨ 优化 2：日期字体由 .black 降为 .bold
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .tracking(2)
                .foregroundColor(isHovered ? .twIndigo500 : (isDark ? .twSlate500 : .twSlate400))
                .opacity(isHovered ? 1.0 : 0.6)
            
            if rating >= 4 {
                HStack(spacing: 4) {
                    Text("🔥 强推")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundColor(.orange)
                .padding(.horizontal, 12).padding(.vertical, 4)
                .background(Color.orange.opacity(0.1))
                .clipShape(Capsule())
            }
        }
        .offset(y: isHovered ? -4 : 0)
    }
}

// MARK: - 3D 悬浮书籍卡片
struct TimelineCardView: View {
    let book: Book
    let isCardOnLeft: Bool
    let isDark: Bool
    @Binding var isHovered: Bool
    
    var body: some View {
        HStack(spacing: 24) {
            if isCardOnLeft {
                textSection
                coverSection
            } else {
                coverSection
                textSection
            }
        }
        .padding(24)
        .frame(width: 420)
        // ================= 背景与装饰 =================
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(isDark ? Color.twSlate900.opacity(0.6) : Color.white.opacity(0.7))
                
                GeometryReader { geo in
                    ZStack {
                        Circle()
                            .fill(Color.twIndigo500)
                            .frame(width: 150, height: 150)
                            .blur(radius: 40)
                            .scaleEffect(isHovered ? 2.5 : 0.5)
                            .opacity(isHovered ? (isDark ? 0.35 : 0.2) : 0.0)
                        
                        Image(systemName: "touchid")
                            .font(.system(size: 180, weight: .ultraLight))
                            .foregroundColor(isDark ? Color.white.opacity(0.04) : Color.black.opacity(0.03))
                            .scaleEffect(isHovered ? 1.08 : 1.0)
                    }
                    .rotationEffect(.degrees(15))
                    .position(x: isCardOnLeft ? 0 : geo.size.width, y: geo.size.height)
                    
                    ZStack {
                        Circle()
                            .fill(Color.twIndigo500)
                            .frame(width: 80, height: 80)
                            .blur(radius: 30)
                            .scaleEffect(isHovered ? 2.0 : 0.5)
                            .opacity(isHovered ? (isDark ? 0.25 : 0.15) : 0.0)
                        
                        Image(systemName: "quote.opening")
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(isDark ? Color.twIndigo500.opacity(0.15) : Color.twIndigo500.opacity(0.08))
                            .scaleEffect(isHovered ? 1.15 : 1.0)
                    }
                    .position(x: isCardOnLeft ? 40 : geo.size.width - 40, y: 40)
                    
                }.clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(isHovered ? Color.twIndigo500.opacity(0.4) : (isDark ? Color.white.opacity(0.05) : Color.white.opacity(0.6)), lineWidth: 1))
        .shadow(color: Color.black.opacity(isDark ? (isHovered ? 0.4 : 0.2) : (isHovered ? 0.15 : 0.05)), radius: isHovered ? 30 : 15, y: isHovered ? 15 : 8)
        .offset(y: isHovered ? -8 : 0)
        .contentShape(Rectangle())
        .onHover { h in withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) { isHovered = h } }
    }
    
    // MARK: - 图片模块
    @ViewBuilder
    private var coverSection: some View {
        Color.clear
            .aspectRatio(2.0 / 3.0, contentMode: .fit)
            .overlay(LocalCoverView(coverData: book.coverData, fallbackTitle: book.title).frame(maxWidth: .infinity, maxHeight: .infinity).clipped())
            .frame(width: 110)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(isDark ? Color.white.opacity(0.1) : Color.black.opacity(0.05), lineWidth: 1))
            .shadow(color: Color.twIndigo500.opacity(isHovered ? 0.3 : 0.0), radius: isHovered ? 15 : 0, y: isHovered ? 10 : 0)
            .scaleEffect(isHovered ? 1.05 : 1.0)
    }
    
    // MARK: - 文本模块
    @ViewBuilder
    private var textSection: some View {
        VStack(alignment: isCardOnLeft ? .trailing : .leading, spacing: 8) {
            Text(book.title)
                // ✨ 优化 3：书名由 .black 降为 .bold
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(isHovered ? .twIndigo500 : (isDark ? .white : .twSlate800))
                .lineLimit(2)
                .multilineTextAlignment(isCardOnLeft ? .trailing : .leading)
            
            Text(book.author)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(isDark ? .twSlate400 : .twSlate500)
                .lineLimit(1)
                .multilineTextAlignment(isCardOnLeft ? .trailing : .leading)
            
            if book.rating > 0 {
                HStack(spacing: 4) {
                    ForEach(1...5, id: \.self) { i in
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(i <= book.rating ? .yellow : (isDark ? .twSlate700 : .twSlate200))
                            .shadow(color: i <= book.rating ? Color.yellow.opacity(0.4) : .clear, radius: 4)
                    }
                }
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, alignment: isCardOnLeft ? .trailing : .leading)
    }
}

// ===============================================
// ✨ 独立预览环境
// ===============================================
#Preview("Light Mode - Yearly Timeline") {
    YearlyTimelineView(books: PreviewData.allMockBooks)
        .frame(width: 1200, height: 900)
        .preferredColorScheme(.light)
        .modelContainer(PreviewData.shared)
}

#Preview("Dark Mode - Yearly Timeline") {
    YearlyTimelineView(books: PreviewData.allMockBooks)
        .frame(width: 1200, height: 900)
        .preferredColorScheme(.dark)
        .modelContainer(PreviewData.shared)
}
