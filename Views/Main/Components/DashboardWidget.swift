import SwiftUI
import SwiftData

struct DashboardWidget: View {
    @Environment(\.colorScheme) var colorScheme
    @Query var allBooks: [Book]
    @Query var allRecords: [ReadingRecord]
    
    @State private var hasCheckedIn = false
    
    // ================== 🧠 数据库联合计算中枢 ==================
    
    // 1. 年度数据：今年已读完的书籍数量
    var yearlyCount: Int {
        let currentYear = Calendar.current.component(.year, from: Date())
        return allBooks.filter { book in
            if book.status == "FINISHED", let endTime = book.endTime {
                return Calendar.current.component(.year, from: endTime) == currentYear
            }
            return false
        }.count
    }
    
    // 2. 月度数据：本月总共打卡了几天
    var monthlyDays: Int {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: Date())
        let currentYear = calendar.component(.year, from: Date())
        
        let thisMonthRecords = allRecords.filter {
            calendar.component(.year, from: $0.date) == currentYear &&
            calendar.component(.month, from: $0.date) == currentMonth
        }
        // 使用 Set 去重，防止一天多次打卡导致数据虚高
        let uniqueDays = Set(thisMonthRecords.map { calendar.component(.day, from: $0.date) })
        return uniqueDays.count
    }
    
    // 3. 周度数据：本周打卡矩阵状态与总数
    var weeklyData: (matrix: [Bool], count: Int) {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // 设定周一为每周第一天
        let today = Date()
        
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        guard let startOfWeek = calendar.date(from: components) else {
            return (Array(repeating: false, count: 7), 0)
        }
        
        var matrix = Array(repeating: false, count: 7)
        var count = 0
        
        for i in 0..<7 {
            if let dayDate = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                // 检查这一天是否有记录
                let hasRecord = allRecords.contains { calendar.isDate($0.date, inSameDayAs: dayDate) }
                matrix[i] = hasRecord
                if hasRecord { count += 1 }
            }
        }
        return (matrix, count)
    }
    
    // 4. 定位“今天”在星期矩阵中的索引 (周一 = 0, 周日 = 6)
    var todayIndex: Int {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let weekday = calendar.component(.weekday, from: Date())
        return (weekday + 5) % 7
    }
    
    // =======================================================
    
    var body: some View {
        let isDark = colorScheme == .dark
        ZStack {
            GeometryReader { geo in
                Circle().fill(isDark ? Color.twBlue600.opacity(0.1) : Color.twBlue300.opacity(0.3)).frame(width: 500, height: 500).blur(radius: 100).position(x: 0, y: 0)
                Circle().fill(isDark ? Color.twPurple600.opacity(0.1) : Color.twPurple300.opacity(0.3)).frame(width: 400, height: 400).blur(radius: 100).position(x: geo.size.width, y: geo.size.height)
            }.allowsHitTesting(false)
            
            VStack(spacing: 24) {
                HStack {
                    Text("阅读看板").font(.system(size: 24, weight: .black)).foregroundColor(isDark ? .white : .twSlate800)
                    Spacer()
                    CheckInButton(hasCheckedIn: $hasCheckedIn)
                }
                .padding(.horizontal, 4)
                
                HStack(spacing: 24) {
                    // ✨ 数据注入：年度卡片
                    YearReadingCard(count: yearlyCount)
                    // ✨ 数据注入：月度卡片
                    MonthReadingCard(days: monthlyDays)
                }
                .frame(height: 180)
                
                // ✨ 数据注入：周度矩阵
                WeeklyEnergyMatrix(
                    continuousDays: weeklyData.count,
                    weekData: weeklyData.matrix,
                    todayIndex: todayIndex
                ).frame(height: 170)
            }
            .padding(40)
        }
        .outerGlassBlockStyle()
        .onAppear {
            // 初始化同步今日打卡状态
            hasCheckedIn = allRecords.contains { Calendar.current.isDate($0.date, inSameDayAs: Date()) }
        }
    }
}

#Preview("完整数据看板") {
    DashboardWidget()
        .padding(30)
        .frame(width: 700)
        .background(Color.gray.opacity(0.1))
}
