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
    @State private var isPulsing = false
    
    let ratingTexts = ["", "一星毒草", "二星平庸", "三星粮草", "四星推荐", "🔥 改变人生"]
    
    var body: some View {
        let isDark = colorScheme == .dark
        
        let titleColor = isHovered ? Color.twIndigo500 : (isDark ? Color.twSlate100 : Color.twSlate800)
        let authorColor = isDark ? Color.twSlate400 : Color.twSlate500
        let shadowColor = Color.black.opacity(isHovered ? (isDark ? 0.4 : 0.2) : 0.05)
        let borderOverlayColor = isDark ? Color.white.opacity(0.15) : Color.black.opacity(0.08) // 稍微加深一点边框质感
        
        VStack(alignment: .leading, spacing: 12) {
            // ================= 1. 封面区 =================
            // ✨ 去掉了透明卡片，只保留封面和右上角的标签！
            ZStack(alignment: .topTrailing) {
                // ================= 1. 封面区 =================
                ZStack(alignment: .topTrailing) {
                    if selectedBook?.id != book.id {
                        Color.clear
                            .overlay(LocalCoverView(coverData: book.coverData, fallbackTitle: book.title))
                            // 1. 裁剪圆角
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            // 2. 将边框纹在图片上
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(borderOverlayColor, lineWidth: 1)
                            )
                            // 3. ✨ 挂载引擎，连带边框一起飞走！
                            .matchedGeometryEffect(id: "gallery-\(book.id)", in: namespace)
                            // 4. 定死骨架尺寸！让画廊所有卡片像阅兵一样整齐！
                            .frame(width: 160, height: 240)
                    } else {
                        Color.clear
                            .frame(width: 160, height: 240)
                        // 👉 状态 B：被选中起飞后留下的替身
//                        LocalCoverView(coverData: book.coverData, fallbackTitle: book.title)
//                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
//                            .frame(width: 160, height: 240)
//                            .opacity(0.001)
//                            .zIndex(0)
                    }
                }
            }
            .frame(width: 160, height: 240)
            // ✨ 悬浮感直接作用于封面！
            .shadow(color: shadowColor, radius: isHovered ? 20 : 8, y: isHovered ? 12 : 4)
            .offset(y: isHovered ? -8 : 0)
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .zIndex(selectedBook?.id == book.id ? 999 : 0)
            
            // ================= 2. 文本信息区 =================
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title).font(.system(size: 16, weight: .bold)).foregroundColor(titleColor).lineLimit(1)
                Text(book.author).font(.system(size: 13, weight: .bold)).foregroundColor(authorColor).lineLimit(1)
                
                if isFinishedTab && book.status == "FINISHED" {
                    FinishedStatsView(book: book, isDark: isDark, ratingTexts: ratingTexts)
                }
            }
            .padding(.horizontal, 4)
            .frame(width: 160, alignment: .leading) // 确保文字和封面等宽
            .zIndex(0)
        }
        .contentShape(Rectangle())
        .onHover { h in withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { isHovered = h } }
        .onAppear { withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) { isPulsing = true } }
        .zIndex(selectedBook?.id == book.id ? 999 : 0)
    }
}

/// 战报区组件
struct FinishedStatsView: View {
    let book: Book
    let isDark: Bool
    let ratingTexts: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider().background(isDark ? Color.twSlate800 : Color.twSlate200).padding(.top, 4)
            
            HStack {
                HStack(spacing: 2) {
                    if book.rating > 0 {
                        ForEach(1 ... 5, id: \.self) { i in
                            Image(systemName: "star.fill").font(.system(size: 10))
                                .foregroundColor(i <= book.rating ? .yellow : (isDark ? .twSlate700 : .twSlate200))
                        }
                    } else {
                        Text("暂无评分").font(.system(size: 10, weight: .bold)).foregroundColor(.twSlate400).tracking(1)
                    }
                }
                Spacer()
                if book.rating > 0 {
                    Text(ratingTexts[book.rating]).font(.system(size: 10, weight: .bold)).foregroundColor(isDark ? .twOrange500 : .orange)
                }
            }
            
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "calendar").font(.system(size: 10))
                    Text("\(formatShortDate(book.startTime)) - \(formatShortDate(book.endTime))").font(.system(size: 10, weight: .bold))
                }.foregroundColor(isDark ? .twSlate500 : .twSlate400)
                
                Spacer()
                Text("历时 \(calculateDays(start: book.startTime, end: book.endTime)) 天").font(.system(size: 10, weight: .bold))
                    .foregroundColor(isDark ? .twIndigo400 : .twIndigo500)
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(isDark ? Color.twIndigo500.opacity(0.1) : Color.twIndigo500.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            
            if !book.tags.isEmpty {
                HStack(spacing: 6) {
                    ForEach(Array(book.tags.prefix(3)), id: \.self) { tag in
                        Text(tag).font(.system(size: 9, weight: .bold)).foregroundColor(isDark ? .twSlate400 : .twSlate500).textCase(.uppercase)
                            .padding(.horizontal, 6).padding(.vertical, 3)
                            .background(isDark ? Color.twSlate800 : Color.twSlate100)
                            .overlay(RoundedRectangle(cornerRadius: 4).stroke(isDark ? Color.twSlate700 : Color.twSlate200, lineWidth: 1))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }.padding(.top, 2)
            }
        }
    }
    
    private func formatShortDate(_ date: Date?) -> String {
        guard let d = date else { return "?" }
        let formatter = DateFormatter(); formatter.dateFormat = "yy/MM/dd"; return formatter.string(from: d)
    }

    private func calculateDays(start: Date?, end: Date?) -> Int {
        guard let s = start, let e = end else { return 1 }
        let days = Calendar.current.dateComponents([.day], from: s, to: e).day ?? 0
        return days <= 0 ? 1 : days
    }
}

/// 状态标签组件 (重新设计为贴合书角的样式)
struct StatusPill: View {
    let status: String
    let isPulsing: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        let isDark = colorScheme == .dark
        let label = status == "FINISHED" ? "已读" : (status == "READING" ? "在读" : "待读")
        let dotColor = status == "FINISHED" ? Color.twEmerald500 : (status == "READING" ? Color.twIndigo500 : Color.twSlate400)
        let textColor = status == "FINISHED" ? (isDark ? Color.twEmerald400 : Color.twEmerald600) : (status == "READING" ? (isDark ? Color.twIndigo400 : Color.twIndigo600) : (isDark ? Color.twSlate300 : Color.twSlate600))
        let bgColor = status == "FINISHED" ? (isDark ? Color.twEmerald500.opacity(0.15) : Color.twEmerald500.opacity(0.1)) : (status == "READING" ? (isDark ? Color.twIndigo500.opacity(0.15) : Color.twIndigo500.opacity(0.1)) : (isDark ? Color.twSlate800.opacity(0.85) : Color.twSlate100.opacity(0.95)))
        let borderColor = status == "FINISHED" ? Color.twEmerald500.opacity(0.3) : (status == "READING" ? Color.twIndigo500.opacity(0.3) : Color.twSlate500.opacity(0.3))

        HStack(spacing: 6) {
            Circle()
                .fill(dotColor)
                // ✨ 圆点变大
                .frame(width: 8, height: 8)
                .shadow(color: dotColor.opacity(0.8), radius: isPulsing ? 4 : 0)
                .scaleEffect(isPulsing ? 1.2 : 1.0)
            
            Text(label)
                // ✨ 字体变大、加粗
                .font(.system(size: 12, weight: .black))
                .tracking(1)
        }
        .foregroundColor(textColor)
        // ✨ 内边距加大
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        // ✨ 加入毛玻璃材质，叠加在封面上更好看
        .background(.ultraThinMaterial)
        .background(bgColor)
        // ✨ 核心魔法：使用和封面完全一致的 16 圆角，但如果是最新系统可以采用书签风格
        // (如果你使用的是 macOS 13+ / iOS 16+，UnevenRoundedRectangle 会让它完美贴合右上角和左下角)
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 16, bottomTrailingRadius: 0, topTrailingRadius: 16))
        .overlay(UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 16, bottomTrailingRadius: 0, topTrailingRadius: 16).stroke(borderColor, lineWidth: 1))
    }
}
