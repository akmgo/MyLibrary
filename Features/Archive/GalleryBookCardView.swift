import SwiftData
import SwiftUI

struct GalleryBookCardView: View {
    let book: Book
    let showStatus: Bool
    let isFinishedTab: Bool
    let namespace: Namespace.ID
    let activeCoverID: String
    let selectedBook: Book?
    
    @Environment(\.colorScheme) var colorScheme
    @State private var isHovered = false
    
    let ratingTexts = ["", "一星毒草", "二星平庸", "三星粮草", "四星推荐", "🔥 改变人生"]
    
    var body: some View {
        let isDark = colorScheme == .dark
        
        let titleColor = isHovered ? Color.twIndigo600 : (isDark ? Color.white : Color.twSlate800)
        let authorColor = isDark ? Color.twSlate400 : Color.twSlate500
        let hoverShadowColor = Color.black.opacity(isDark ? 0.4 : 0.15)
        
        VStack(alignment: .leading, spacing: 12) {
            // ================= 1. 纯净的封面区 =================
            ZStack(alignment: .topTrailing) {
                if selectedBook?.id != book.id {
                    // ✨ 修复 1：改回你目前稳定高性能的传参方式
                    LocalCoverView(coverData: book.coverData, fallbackTitle: book.title)
                        .frame(width: 160, height: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(isDark ? Color.white.opacity(0.1) : Color.black.opacity(0.05), lineWidth: 1))
                        .matchedGeometryEffect(id: "gallery-\(book.id)", in: namespace, isSource: selectedBook?.id != book.id)
                        .opacity(selectedBook?.id == book.id ? 0.001 : 1.0)
                } else {
                    Color.clear.frame(width: 160, height: 240)
                }
            }
            .frame(width: 160, height: 240)
            .shadow(color: isHovered ? hoverShadowColor : .clear, radius: isHovered ? 20 : 0, y: isHovered ? 12 : 0)
            .offset(y: isHovered ? -8 : 0)
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .zIndex(selectedBook?.id == book.id ? 999 : 0)
            
            // ================= 2. 紧凑的文本信息区 =================
            VStack(alignment: .leading, spacing: 2) {
                Text(book.title)
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(titleColor)
                    .lineLimit(1)
                Text(book.author)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(authorColor)
                    .lineLimit(1)
                    .padding(.top, 2)
                
                if isFinishedTab && book.status == "FINISHED" {
                    GalleryStatsView(book: book, isDark: isDark, ratingTexts: ratingTexts)
                }
            }
            .padding(.horizontal, 4)
            .frame(width: 160, alignment: .leading)
            .zIndex(0)
        }
        .contentShape(Rectangle())
        .onHover { h in withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) { isHovered = h } }
        .pointingHand()
        .zIndex(selectedBook?.id == book.id ? 999 : 0)
    }
}

// MARK: - 专属私有组件：极简战报区
private struct GalleryStatsView: View {
    let book: Book
    let isDark: Bool
    let ratingTexts: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
                .background(isDark ? Color.twSlate800.opacity(0.6) : Color.twSlate200.opacity(0.6))
                .padding(.top, 10)
            
            // 1. 评分行
            HStack(alignment: .center) {
                HStack(spacing: 2) {
                    if book.rating > 0 {
                        ForEach(1 ... 5, id: \.self) { i in
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
                                // ✨ 修复 2：将未定义的 twAmber 替换为原生的 yellow
                                .foregroundColor(i <= book.rating ? .yellow : (isDark ? .twSlate700 : .twSlate200))
                                .shadow(color: i <= book.rating ? Color.yellow.opacity(0.4) : .clear, radius: 2)
                        }
                    } else {
                        Text("暂无评分")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.twSlate400)
                            .tracking(1)
                    }
                }
                Spacer()
                if book.rating > 0 {
                    Text(ratingTexts[book.rating])
                        .font(.system(size: 10, weight: .bold))
                        // ✨ 修复 2：替换为原生的 orange
                        .foregroundColor(isDark ? .orange : Color.orange.opacity(0.8))
                }
            }
            
            // 2. 时间与历时行
            HStack(alignment: .center) {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: 10))
                    Text("\(formatShortDate(book.startTime)) - \(formatShortDate(book.endTime))")
                        .font(.system(size: 10, weight: .bold))
                }
                .foregroundColor(isDark ? .twSlate500 : .twSlate400)
                
                Spacer()
                
                Text("历时 \(calculateDays(start: book.startTime, end: book.endTime)) 天")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(isDark ? .twIndigo400 : .twIndigo500)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(isDark ? Color.twIndigo500.opacity(0.1) : Color.twIndigo50.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .shadow(color: .black.opacity(0.02), radius: 2)
            }
            
            // 3. 标签行
            if !book.tags.isEmpty {
                HStack(spacing: 6) {
                    ForEach(Array(book.tags.prefix(3)), id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(isDark ? .twSlate400 : .twSlate500)
                            .textCase(.uppercase)
                            .tracking(1)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(isDark ? Color.twSlate800 : Color.twSlate100)
                            .overlay(RoundedRectangle(cornerRadius: 4).stroke(isDark ? Color.twSlate700.opacity(0.5) : Color.twSlate200.opacity(0.5), lineWidth: 1))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
                .padding(.top, 2)
            }
        }
    }
    
    private func formatShortDate(_ date: Date?) -> String {
        guard let d = date else { return "?" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yy/MM/dd"
        return formatter.string(from: d)
    }
    
    private func calculateDays(start: Date?, end: Date?) -> Int {
        guard let s = start, let e = end else { return 1 }
        let days = Calendar.current.dateComponents([.day], from: s, to: e).day ?? 0
        return days <= 0 ? 1 : days
    }
}
