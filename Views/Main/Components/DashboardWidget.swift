import SwiftUI

struct DashboardWidget: View {
    @State private var hasCheckedIn = false
    @Environment(\.colorScheme) var colorScheme
    
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
                    YearReadingCard(count: 15)
                    MonthReadingCard(days: 4)
                }
                .frame(height: 180)
                
                WeeklyEnergyMatrix(continuousDays: 1, weekData: [false, true, false, false, false, false, false]).frame(height: 170)
            }
            .padding(40)
        }
        .outerGlassBlockStyle()
    }
}

#Preview("完整数据看板") {
    DashboardWidget()
        .padding(30)
        .frame(width: 700)
        .background(Color.gray.opacity(0.1))
}
