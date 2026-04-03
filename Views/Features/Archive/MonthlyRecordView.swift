import SwiftData
import SwiftUI

struct MonthlyRecordView: View {
    @Environment(\.colorScheme) var colorScheme
    @Query var allRecords: [ReadingRecord] // 获取所有打卡记录
    
    @State private var currentDate = Date()
    
    let daysOfWeek = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"]
    
    var body: some View {
        let isDark = colorScheme == .dark
        
        ScrollView(.vertical, showsIndicators: false) {
            // ================= 月历核心画板 =================
            VStack(spacing: 24) {
                // ================= 月份标题栏 (带跨月穿梭引擎) =================
                HStack(alignment: .center, spacing: 16) {
                    // 左切换按钮：上个月
                    Button(action: { changeMonth(by: -1) }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(isDark ? .twSlate400 : .twSlate500)
                            .frame(width: 36, height: 36)
                            .background(isDark ? Color.twSlate800.opacity(0.8) : Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(isDark ? 0.2 : 0.05), radius: 4, y: 2)
                    }
                    .buttonStyle(.plain)
                                    
                    // 月份文本
                    Text(formattedYearMonth(currentDate))
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(isDark ? .white : .twSlate800)
                        // 固定宽度，防止切换月份时因为文字长短导致按钮左右横跳
                        .frame(width: 150)
                                    
                    // 右切换按钮：下个月
                    Button(action: { changeMonth(by: 1) }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(isDark ? .twSlate400 : .twSlate500)
                            .frame(width: 36, height: 36)
                            .background(isDark ? Color.twSlate800.opacity(0.8) : Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(isDark ? 0.2 : 0.05), radius: 4, y: 2)
                    }
                    .buttonStyle(.plain)
                                    
                    // 渐变能量分割线
                    Rectangle()
                        .fill(LinearGradient(colors: [isDark ? Color.twIndigo500 : Color.twIndigo400, .clear], startPoint: .leading, endPoint: .trailing))
                        .frame(height: 2)
                        .padding(.leading, 12)
                }
                .padding(.horizontal, 32)
                .padding(.top, 32)
                
                // 星期表头
                HStack(spacing: 0) {
                    ForEach(daysOfWeek, id: \.self) { day in
                        Text(day)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(isDark ? .twSlate400 : .twSlate500)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, 32)
                
                // ✨ 日历网格区：LazyVGrid 负责自动排版
                // columns 设置 spacing 为 20，让卡片之间有呼吸感
                let columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 7)
                let daysInMonth = extractDaysInMonth(for: currentDate)
                
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(0..<daysInMonth.count, id: \.self) { index in
                        if let date = daysInMonth[index] {
                            // ✨ 渲染真实的每一天（在这里我们已经把 DayCardView 传给了格子）
                            DayCardView(date: date, records: allRecords, isDark: isDark)
                        } else {
                            // 留白占位符：同样保持 160x240 大小
                            Color.clear.frame(width: 160, height: 240)
                        }
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
            // 整个日历的底层磨砂玻璃
            .background(isDark ? Color.twSlate900.opacity(0.4) : Color.white.opacity(0.6))
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 32, style: .continuous).stroke(isDark ? Color.twSlate700.opacity(0.5) : Color.white, lineWidth: 1))
            .shadow(color: .black.opacity(isDark ? 0.3 : 0.05), radius: 30, y: 15)
            .padding(.horizontal, 40)
            // 顶部留白避开导航栏，底部留白避开边缘
            .padding(.top, 120)
            .padding(.bottom, 80)
        }
        // ✨ 打破顶部灰色安全区结界！
        .ignoresSafeArea(edges: .top)
    }
    
    // MARK: - 辅助算法 (保持不变)

    private func formattedYearMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年 M月"
        return formatter.string(from: date)
    }
    
    private func extractDaysInMonth(for date: Date) -> [Date?] {
        let calendar = Calendar.current
        var days = [Date?]()
        
        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
              let firstDayOfMonth = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: monthInterval.start) else { return [] }
        
        // 获取第一天是星期几 (周日是1，周一是2...我们需要转换成周一是1，周日是7)
        let component = calendar.component(.weekday, from: firstDayOfMonth)
        let emptyDaysBefore = (component + 5) % 7
        
        // 填充前面的空白
        for _ in 0..<emptyDaysBefore {
            days.append(nil)
        }
        
        // 填充真实日期
        let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth)!
        for i in 0..<range.count {
            if let dayDate = calendar.date(byAdding: .day, value: i, to: firstDayOfMonth) {
                days.append(dayDate)
            }
        }
        
        return days
    }
    
    // MARK: - 跨月穿梭算法

    private func changeMonth(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: currentDate) {
            // 加上绝美的弹簧动画，切换月份时日历网格会平滑变形过渡
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                currentDate = newDate
            }
        }
    }
}

// MARK: - ✨ 单个日历卡片 (DayCardView - 动静分离排版)

struct DayCardView: View {
    let date: Date
    let records: [ReadingRecord]
    let isDark: Bool
    
    /// ✨ 定义核心高定尺寸：160x240 (竖状比例)
    let cardSize = CGSize(width: 160, height: 240)
    
    var body: some View {
        let calendar = Calendar.current
        let isToday = calendar.isDateInToday(date)
        
        // 查找今天是否有打卡记录
        let dayRecord = records.first { calendar.isDate($0.date, inSameDayAs: date) }
        let hasRead = dayRecord != nil
        
        ZStack {
            // ================= 1. 坑槽基础背景层 =================
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(hasRead ? (isDark ? Color.twIndigo600.opacity(0.15) : Color.twIndigo50) : (isDark ? Color.twSlate950.opacity(0.3) : Color.white.opacity(0.6)))
            
            // ✨ 优化：加深浅色模式下的空边框颜色，使其清晰可见 (.twSlate300)
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(hasRead ? Color.twIndigo500 : (isDark ? Color.twSlate800 : Color.twSlate300), lineWidth: hasRead ? 1.5 : 1)
            
            // ================= 2. 已打卡：全息投影层 (仅展示封面) =================
            if let record = dayRecord, let book = record.book {
                // 有关联书籍：用 LocalCoverView 填充整个卡片
                LocalCoverView(coverData: book.coverData, fallbackTitle: book.title)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(LinearGradient(colors: [.clear, .white.opacity(0.3), .clear], startPoint: .topLeading, endPoint: .bottomTrailing))
                    )
            } else if hasRead {
                // 仅打卡，未关联书籍：默认火焰卡片
                ZStack {
                    LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
                    Image(systemName: "flame.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.white.opacity(0.8))
                }
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            
            // ================= 3. ✨ 日期排版引擎 (动静分离) =================
            let dateString = "\(calendar.component(.day, from: date))"
            
            if hasRead {
                // 📚 状态 A：已读 -> 日期缩至右下角，给封面让位
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(dateString)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            // 统一白色，并加阴影防止和白色封面融为一体
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.6), radius: 2, y: 1)
                            .overlay(
                                Circle().fill(Color.red).frame(width: 4, height: 4).offset(y: -12)
                                    .opacity(isToday ? 1 : 0)
                            )
                    }
                }
                .padding(12)
            } else {
                // ⬜️ 状态 B：未读 -> 巨大的日期居中，填满格子
                Text(dateString)
                    // ✨ 使用 28pt 大字号，如果是今天加粗变黑
                    .font(.system(size: 28, weight: isToday ? .black : .bold, design: .rounded))
                    .foregroundColor(isToday ? (isDark ? .white : .twSlate800) : (isDark ? .twSlate600 : .twSlate400))
                    .overlay(
                        // 今天的红点移到大字的右上角
                        Circle().fill(Color.red).frame(width: 6, height: 6).offset(x: 18, y: -16)
                            .opacity(isToday ? 1 : 0)
                    )
            }
        }
        .frame(width: cardSize.width, height: cardSize.height)
        // 读了就给卡片加上紫色的荧光投影，没读也给浅色加极其微弱的阴影以提升立体感
        .shadow(color: hasRead ? Color.twIndigo500.opacity(isDark ? 0.3 : 0.15) : (isDark ? .clear : .black.opacity(0.02)), radius: hasRead ? 20 : 10, y: hasRead ? 10 : 4)
    }
}
