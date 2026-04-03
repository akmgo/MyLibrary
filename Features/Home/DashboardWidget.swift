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
        calendar.firstWeekday = 2 // 周一为每周第一天
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
            GeometryReader { geo in
                Circle().fill(isDark ? Color.twBlue600.opacity(0.1) : Color.twBlue300.opacity(0.3)).frame(width: 500, height: 500).blur(radius: 100).position(x: 0, y: 0)
                Circle().fill(isDark ? Color.twPurple600.opacity(0.1) : Color.twPurple300.opacity(0.3)).frame(width: 400, height: 400).blur(radius: 100).position(x: geo.size.width, y: geo.size.height)
            }.allowsHitTesting(false)
            
            VStack(spacing: 24) {
                HStack {
                    Text("阅读看板").font(.system(size: 24, weight: .black)).foregroundColor(isDark ? .white : .twSlate800)
                    Spacer()
                    CheckInButton(hasCheckedIn: $hasCheckedIn)
                }.padding(.horizontal, 4)
                
                HStack(spacing: 24) {
                    YearReadingCard(count: yearlyCount)
                    MonthReadingCard(days: monthlyDays)
                }.frame(height: 180)
                
                WeeklyEnergyMatrix(continuousDays: weeklyData.count, weekData: weeklyData.matrix, todayIndex: todayIndex)
                    .frame(height: 170)
            }.padding(40)
        }
        .padding(20)
        .outerGlassBlockStyle()
        .onAppear {
            hasCheckedIn = allRecords.contains { Calendar.current.isDate($0.date, inSameDayAs: Date()) }
        }
    }
}
