import SwiftUI
import SwiftData

struct DashboardWidget: View {
    @Environment(\.colorScheme) var colorScheme
    @Query var allBooks: [Book]
    @Query var allRecords: [ReadingRecord]
    
    @State private var hasCheckedIn = false
    
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
    
    var weeklyData: (matrix: [Bool], count: Int) {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let today = Date()
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) else {
            return (Array(repeating: false, count: 7), 0)
        }
        
        var matrix = Array(repeating: false, count: 7)
        var count = 0
        for i in 0..<7 {
            if let dayDate = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                let hasRecord = allRecords.contains { calendar.isDate($0.date, inSameDayAs: dayDate) }
                matrix[i] = hasRecord
                if hasRecord { count += 1 }
            }
        }
        return (matrix, count)
    }
    
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
            // 背景光晕
            GeometryReader { geo in
                Circle().fill(isDark ? Color.twBlue600.opacity(0.1) : Color.twBlue300.opacity(0.3)).frame(width: 500, height: 500).blur(radius: 100).position(x: 0, y: 0)
                Circle().fill(isDark ? Color.twPurple600.opacity(0.1) : Color.twPurple300.opacity(0.3)).frame(width: 400, height: 400).blur(radius: 100).position(x: geo.size.width, y: geo.size.height)
            }.allowsHitTesting(false)
            
            VStack(spacing: 15) {
                // 1. 标题栏 (去掉了多余的 .padding(.horizontal, 4))
                HStack {
                    Text("阅读看板").font(.system(size: 24, weight: .regular)).foregroundColor(isDark ? .white : .twSlate800)
                    Spacer()
                    CheckInButton(hasCheckedIn: $hasCheckedIn)
                }
                .frame(height: 44)
                
                // 2. 中间卡片
                HStack(spacing: 24) {
                    YearReadingCard(count: yearlyCount)
                    MonthReadingCard(days: monthlyDays)
                }.frame(height: 180)
                
                // ✨ 魔法 2：利用 Spacer 将热力图强行推到最底部
                Spacer(minLength: 0)
                
                // 3. 底部卡片
                WeeklyEnergyMatrix(continuousDays: weeklyData.count, weekData: weeklyData.matrix, todayIndex: todayIndex)
                    .frame(height:200)
            }
            // ✨ 魔法 1：全局只保留这一个极其标准的内边距，统一四周间距
            .padding(30)
        }
        // ✨ 魔法 3：让卡片高度自适应拉伸，配合隔壁的卡片保持等高
        .frame(maxHeight: .infinity)
        .outerGlassBlockStyle()
        .onAppear {
            hasCheckedIn = allRecords.contains { Calendar.current.isDate($0.date, inSameDayAs: Date()) }
        }
    }
}

