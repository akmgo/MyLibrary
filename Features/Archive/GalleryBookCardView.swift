import SwiftData
import SwiftUI

struct GalleryBookCardView: View {
    let book: Book
    let showStatus: Bool
    let isFinishedTab: Bool
    let namespace: Namespace.ID
    let activeCoverID: String
    let selectedBook: Book?
    
    var onHoverColorChange: ((Color?) -> Void)? = nil
    
    @Environment(\.colorScheme) var colorScheme
    @State private var isHovered = false
    
    @State private var ambientColor: Color = .twIndigo500
    
    let ratingTexts = ["", "一星毒草", "二星平庸", "三星粮草", "四星推荐", "🔥 改变人生"]
    
    var body: some View {
        let isDark = colorScheme == .dark
        let titleColor = isHovered ? Color.twIndigo500 : (isDark ? Color.white : Color.twSlate800)
        let authorColor = isDark ? Color.twSlate400 : Color.twSlate500
        
        VStack(alignment: .leading, spacing: 16) {
            // ================= 1. 极致悬浮封面区 =================
            ZStack(alignment: .topTrailing) {
                if selectedBook?.id != book.id {
                    LocalCoverView(coverData: book.coverData, fallbackTitle: book.title)
                        .frame(width: GalleryConfig.coverWidth, height: GalleryConfig.coverHeight)
                        // ✨ 用系统标准平滑曲线裁切封面，保证圆角完美
                        .appleClip(radius: AppleRadius.regular)
                        .matchedGeometryEffect(id: "gallery-\(book.id)", in: namespace, isSource: selectedBook?.id != book.id)
                } else {
                    Color.clear.frame(width: GalleryConfig.coverWidth, height: GalleryConfig.coverHeight)
                }
            }
            .frame(width: GalleryConfig.coverWidth, height: GalleryConfig.coverHeight)
            // ✨ 1. 精准的系统级弧度边框：严格跟随封面同样的 AppleRadius.regular 弧线！
            .appleBorder(isHovered ? Color.white.opacity(0.6) : (isDark ? Color.white.opacity(0.15) : Color.black.opacity(0.05)), radius: AppleRadius.regular, lineWidth: 1)
            // ✨ 2. 四周发散的大阴影，只投射在封面底下
            .shadow(color: isHovered ? ambientColor.opacity(isDark ? 0.6 : 0.4) : Color.black.opacity(0.15),
                    radius: isHovered ? 35 : 10,
                    x: 0,
                    y: isHovered ? 15 : 5)
            // ✨ 3. 物理脱离感：仅仅封面升空并放大，下方的文字不改变位置
            .offset(y: isHovered ? -8 : 0)
            .scaleEffect(isHovered ? 1.03 : 1.0)
            // 确保所有的动画丝滑过渡
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isHovered)
            .zIndex(selectedBook?.id == book.id ? 999 : 0)
            
            // ================= 2. 文本信息区 =================
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(titleColor)
                    .lineLimit(1)
                    .animation(.easeInOut(duration: 0.25), value: isHovered)
                
                Text(book.author)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(authorColor)
                    .lineLimit(1)
                
                if isFinishedTab && book.status == "FINISHED" {
                    GalleryStatsView(book: book, isDark: isDark, ratingTexts: ratingTexts)
                        .padding(.top, 4)
                }
            }
            .frame(width: GalleryConfig.coverWidth, alignment: .leading)
            .zIndex(0)
        }
        .contentShape(Rectangle())
        // ✨ 将悬浮检测区域挂在整个 VStack 上，但仅封面做视觉变化
        .onHover { h in
            withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) { isHovered = h }
            onHoverColorChange?(h ? ambientColor : nil)}
        // ✨ 当卡片出现时，异步非阻塞地提取颜色
        .task(id: book.id) {
            let color = await CoverColorExtractor.shared.getDominantColor(from: book.coverData, id: book.id)
            // 提取完毕后平滑过渡
            withAnimation(.easeInOut(duration: 0.5)) {
                self.ambientColor = color
                if self.isHovered { self.onHoverColorChange?(color) }
            }
        }
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
                .padding(.top, 6)
            
            // 1. 评分行
            HStack(alignment: .center) {
                HStack(spacing: 2) {
                    if book.rating > 0 {
                        ForEach(1 ... 5, id: \.self) { i in
                            Image(systemName: "star.fill")
                                .font(.system(size: 10))
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
