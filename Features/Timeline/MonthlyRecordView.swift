import SwiftData
import SwiftUI

struct MonthlyRecordView: View {
    @Environment(\.colorScheme) var colorScheme
    @Query var allRecords: [ReadingRecord]
    @State private var currentDate = Date()
    let daysOfWeek = ["周一", "周二", "周三", "周四", "周五", "周六", "周日"]
    
    var body: some View {
        let isDark = colorScheme == .dark
        
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                // 顶部标题控制
                HStack(alignment: .center, spacing: 16) {
                    Button(action: { changeMonth(by: -1) }) {
                        Image(systemName: "chevron.left").font(.system(size: 16, weight: .bold)).foregroundColor(isDark ? .twSlate400 : .twSlate500).frame(width: 36, height: 36).background(isDark ? Color.twSlate800.opacity(0.8) : Color.white).clipShape(Circle()).shadow(color: .black.opacity(isDark ? 0.2 : 0.05), radius: 4, y: 2)
                    }.buttonStyle(.plain).pointingHand()
                    
                    Text(formattedYearMonth(currentDate)).font(.system(size: 28, weight: .black, design: .rounded)).foregroundColor(isDark ? .white : .twSlate800).frame(width: 150)
                    
                    Button(action: { changeMonth(by: 1) }) {
                        Image(systemName: "chevron.right").font(.system(size: 16, weight: .bold)).foregroundColor(isDark ? .twSlate400 : .twSlate500).frame(width: 36, height: 36).background(isDark ? Color.twSlate800.opacity(0.8) : Color.white).clipShape(Circle()).shadow(color: .black.opacity(isDark ? 0.2 : 0.05), radius: 4, y: 2)
                    }.buttonStyle(.plain).pointingHand()
                    
                    Rectangle().fill(LinearGradient(colors: [isDark ? Color.twIndigo500 : Color.twIndigo400, .clear], startPoint: .leading, endPoint: .trailing)).frame(height: 2).padding(.leading, 12)
                }
                .padding(.horizontal, 32).padding(.top, 32)
                
                HStack(spacing: 0) {
                    ForEach(daysOfWeek, id: \.self) { day in
                        Text(day).font(.system(size: 14, weight: .bold)).foregroundColor(isDark ? .twSlate400 : .twSlate500).frame(maxWidth: .infinity)
                    }
                }.padding(.horizontal, 32)
                
                // 日历网格
                let columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 7)
                let daysInMonth = extractDaysInMonth(for: currentDate)
                
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(0..<daysInMonth.count, id: \.self) { index in
                        if let date = daysInMonth[index] {
                            DayCardView(date: date, records: allRecords, isDark: isDark)
                        } else {
                            Color.clear.frame(width: 160, height: 240)
                        }
                    }
                }
                .padding(.horizontal, 32).padding(.bottom, 40)
            }
            .background(isDark ? Color.twSlate900.opacity(0.4) : Color.white.opacity(0.6))
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 32, style: .continuous).stroke(isDark ? Color.twSlate700.opacity(0.5) : Color.white, lineWidth: 1))
            .shadow(color: .black.opacity(isDark ? 0.3 : 0.05), radius: 30, y: 15)
            .padding(.horizontal, 40).padding(.top, 120).padding(.bottom, 80)
        }
        .ignoresSafeArea(edges: .top)
    }
    
    private func formattedYearMonth(_ date: Date) -> String {
        let formatter = DateFormatter(); formatter.dateFormat = "yyyy年 M月"; return formatter.string(from: date)
    }
    
    private func extractDaysInMonth(for date: Date) -> [Date?] {
        let calendar = Calendar.current
        var days = [Date?]()
        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
              let firstDayOfMonth = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: monthInterval.start) else { return [] }
        let component = calendar.component(.weekday, from: firstDayOfMonth)
        let emptyDaysBefore = (component + 5) % 7
        for _ in 0..<emptyDaysBefore { days.append(nil) }
        let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth)!
        for i in 0..<range.count {
            if let dayDate = calendar.date(byAdding: .day, value: i, to: firstDayOfMonth) { days.append(dayDate) }
        }
        return days
    }
    
    private func changeMonth(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: currentDate) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { currentDate = newDate }
        }
    }
}

// 专属私有日历卡片
private struct DayCardView: View {
    let date: Date; let records: [ReadingRecord]; let isDark: Bool
    let cardSize = CGSize(width: 160, height: 240)
    
    var body: some View {
        let calendar = Calendar.current
        let isToday = calendar.isDateInToday(date)
        let dayRecord = records.first { calendar.isDate($0.date, inSameDayAs: date) }
        let hasRead = dayRecord != nil
        
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous).fill(hasRead ? (isDark ? Color.twIndigo600.opacity(0.15) : Color.twIndigo50) : (isDark ? Color.twSlate950.opacity(0.3) : Color.white.opacity(0.6)))
            RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(hasRead ? Color.twIndigo500 : (isDark ? Color.twSlate800 : Color.twSlate300), lineWidth: hasRead ? 1.5 : 1)
            
            if let record = dayRecord, let book = record.book {
                LocalCoverView(coverData: book.coverData, fallbackTitle: book.title)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 16).fill(LinearGradient(colors: [.clear, .white.opacity(0.3), .clear], startPoint: .topLeading, endPoint: .bottomTrailing)))
            } else if hasRead {
                ZStack {
                    LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing)
                    Image(systemName: "flame.fill").font(.system(size: 32)).foregroundColor(.white.opacity(0.8))
                }.clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            
            let dateString = "\(calendar.component(.day, from: date))"
            if hasRead {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(dateString).font(.system(size: 13, weight: .bold, design: .rounded)).foregroundColor(.white).shadow(color: .black.opacity(0.6), radius: 2, y: 1)
                            .overlay(Circle().fill(Color.red).frame(width: 4, height: 4).offset(y: -12).opacity(isToday ? 1 : 0))
                    }
                }.padding(12)
            } else {
                Text(dateString).font(.system(size: 28, weight: isToday ? .black : .bold, design: .rounded))
                    .foregroundColor(isToday ? (isDark ? .white : .twSlate800) : (isDark ? .twSlate600 : .twSlate400))
                    .overlay(Circle().fill(Color.red).frame(width: 6, height: 6).offset(x: 18, y: -16).opacity(isToday ? 1 : 0))
            }
        }
        .frame(width: cardSize.width, height: cardSize.height)
        .shadow(color: hasRead ? Color.twIndigo500.opacity(isDark ? 0.3 : 0.15) : (isDark ? .clear : .black.opacity(0.02)), radius: hasRead ? 20 : 10, y: hasRead ? 10 : 4)
    }
}
