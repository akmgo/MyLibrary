import SwiftUI

struct DashboardWidget: View {
    @State private var hasCheckedIn = false
    
    var body: some View {
        VStack(spacing: 25) {
            // 头部
            HStack {
                Text("阅读看板")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                Spacer()
                CheckInButton(hasCheckedIn: $hasCheckedIn)
            }
            
            // 第一排数据卡片
            HStack(spacing: 20) {
                YearReadingCard(count: 12)
                MonthReadingCard(days: 8)
            }
            .frame(height: 180)
            
            // 第二排能量矩阵
            WeeklyEnergyMatrix(continuousDays: 3, weekData: [true, true, true, false, false, false, false])
                .frame(height: 170)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview("完整数据看板") {
    DashboardWidget()
        .padding(30)
        .frame(width: 700)
        .background(Color.gray.opacity(0.1))
}
