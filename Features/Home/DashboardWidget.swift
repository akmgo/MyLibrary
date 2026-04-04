import SwiftUI
import SwiftData
import Charts

// MARK: - 🍏 极简 Swift Charts 框架版：时光健身环 (真实数据库直连版)
struct DashboardWidget: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var isHovered = false
    
    // ✨ 注入全局数据库
    @Query var allBooks: [Book]
    @Query var allRecords: [ReadingRecord]
    
    // 🎯 目标设定 (后续可以抽到 AppStorage 让用户自行设置)
    let yearTarget = 50.0
    let monthTarget = 30.0
    let weekTarget = 7.0
    
    // ================== 🧠 数据库联合计算中枢 ==================
    var yearlyCount: Int {
        let currentYear = Calendar.current.component(.year, from: Date())
        return allBooks.filter { book in
            if book.status == "FINISHED", let endTime = book.endTime {
                return Calendar.current.component(.year, from: endTime) == currentYear
            }
            return false
        }.count
    }
    
    var monthlyDays: Int {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())
        let thisMonthRecords = allRecords.filter {
            calendar.component(.year, from: $0.date) == currentYear &&
            calendar.component(.month, from: $0.date) == currentMonth
        }
        let uniqueDays = Set(thisMonthRecords.map { calendar.component(.day, from: $0.date) })
        return uniqueDays.count
    }
    
    var weekCount: Int {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // 周一作为第一天
        let today = Date()
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) else { return 0 }
        
        var count = 0
        for i in 0..<7 {
            if let dayDate = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                let hasRecord = allRecords.contains { calendar.isDate($0.date, inSameDayAs: dayDate) }
                if hasRecord { count += 1 }
            }
        }
        return count
    }
    // =======================================================
    
    @State private var animatedWeek: Double = 0.0
    @State private var animatedMonth: Double = 0.0
    @State private var animatedYear: Double = 0.0
    
    let ringOuterSize: CGFloat = 160
    let ringWidth: CGFloat = 18
    let ringSpacing: CGFloat = 2
    
    var body: some View {
        let isDark = colorScheme == .dark
        let colorRed = isDark ? Color(red: 0.90, green: 0.25, blue: 0.40) : Color(red: 0.80, green: 0.15, blue: 0.30)
        let colorGreen = isDark ? Color(red: 0.35, green: 0.80, blue: 0.45) : Color(red: 0.15, green: 0.65, blue: 0.30)
        let colorBlue = isDark ? Color(red: 0.25, green: 0.75, blue: 0.95) : Color(red: 0.10, green: 0.55, blue: 0.80)
        
        let ringMiddleSize = ringOuterSize - (ringWidth * 2) - (ringSpacing * 2)
        let ringInnerSize = ringMiddleSize - (ringWidth * 2) - (ringSpacing * 2)
        
        HStack(spacing: 36) {
            ZStack {
                ChartFitnessRing(progress: animatedWeek / weekTarget, size: ringOuterSize, width: ringWidth, color: colorRed, icon: "arrow.right", isDark: isDark)
                ChartFitnessRing(progress: animatedMonth / monthTarget, size: ringMiddleSize, width: ringWidth, color: colorGreen, icon: "chevron.right.2", isDark: isDark)
                ChartFitnessRing(progress: animatedYear / yearTarget, size: ringInnerSize, width: ringWidth, color: colorBlue, icon: "arrow.up.right", isDark: isDark)
            }
            .padding(.leading, 20)
            
            // 👉 文字排版直接绑定静态计算结果
            VStack(alignment: .leading, spacing: 24) {
                FitnessTextRow(current: weekCount, target: Int(weekTarget), unit: "天", color: colorRed)
                FitnessTextRow(current: monthlyDays, target: Int(monthTarget), unit: "天", color: colorGreen)
                FitnessTextRow(current: yearlyCount, target: Int(yearTarget), unit: "卷", color: colorBlue)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 30)
        .frame(height: 220)
        .homeStaticGlassCardStyle()
        .contentShape(Rectangle())
        .onAppear {
            animatedWeek = Double(weekCount)
            animatedMonth = Double(monthlyDays)
            animatedYear = Double(yearlyCount)
        }
        // ✨ 当数据库有新数据时，圆环自动向前推进！
        .onChange(of: weekCount) { _, new in withAnimation { animatedWeek = Double(new) } }
        .onChange(of: monthlyDays) { _, new in withAnimation { animatedMonth = Double(new) } }
        .onChange(of: yearlyCount) { _, new in withAnimation { animatedYear = Double(new) } }
        .onHover { h in
            isHovered = h
            if h {
                withAnimation(nil) {
                    animatedWeek = 0; animatedMonth = 0; animatedYear = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.75)) {
                        animatedWeek = Double(weekCount)
                        animatedMonth = Double(monthlyDays)
                        animatedYear = Double(yearlyCount)
                    }
                }
            } else {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    animatedWeek = Double(weekCount)
                    animatedMonth = Double(monthlyDays)
                    animatedYear = Double(yearlyCount)
                }
            }
        }
    }
}

// MARK: - ⭕️ 纯 Swift Charts 框架构建的圆环 (保持不变)
private struct ChartFitnessRing: View {
    let progress: Double; let size: CGFloat; let width: CGFloat
    let color: Color; let icon: String; let isDark: Bool
    
    var body: some View {
        let validProgress = min(max(progress, 0), 1.0)
        let leftProgress = 1.0 - validProgress
        
        ZStack {
            Chart {
                SectorMark(angle: .value("Total", 1.0), innerRadius: .inset(width), outerRadius: .inset(0))
                    .foregroundStyle(color.opacity(isDark ? 0.15 : 0.1))
            }
            .chartXAxis(.hidden).chartYAxis(.hidden)
            
            Chart {
                SectorMark(angle: .value("Done", validProgress), innerRadius: .inset(width), outerRadius: .inset(0))
                    .foregroundStyle(color.gradient)
                    .cornerRadius(width / 2)
                
                SectorMark(angle: .value("Left", leftProgress), innerRadius: .inset(width), outerRadius: .inset(0))
                    .foregroundStyle(.clear)
            }
            .chartXAxis(.hidden).chartYAxis(.hidden)
            
            ZStack {
                Circle().fill(color).frame(width: width - 2, height: width - 2)
                Image(systemName: icon)
                    .font(.system(size: width * 0.55, weight: .black))
                    .foregroundColor(isDark ? .black : .white.opacity(0.95))
            }
            .offset(y: -size / 2 + width / 2)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - 📝 视觉子组件：纯净数据排版 (保持不变)
private struct FitnessTextRow: View {
    let current: Int; let target: Int; let unit: String; let color: Color
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text("\(current)/\(target)")
                .font(.system(size: 28, weight: .black, design: .rounded))
            Text(unit)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .opacity(0.8)
        }
        .foregroundColor(color)
    }
}
