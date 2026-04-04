import SwiftUI
import SwiftData
import Charts

struct YearlyHeatmapCard: View {
    @Environment(\.colorScheme) var colorScheme
    // ✨ 接入真实打卡记录
    @Query var allRecords: [ReadingRecord]
    
    @State private var showAnimation = false
    @State private var isHovered = false
    @State private var heatmapData: [HeatmapItem] = []
    
    struct HeatmapItem: Identifiable { let id = UUID(); let week: Int; let day: Int; let intensity: Double }
    
    var body: some View {
        let isDark = colorScheme == .dark
        
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("打卡密度").font(.system(size: 16, weight: .bold, design: .rounded)).foregroundColor(isDark ? .white : .twSlate800)
                }
                Spacer()
                Image(systemName: "square.grid.3x3.fill").foregroundColor(.twIndigo500)
            }
            
            Chart(heatmapData) { item in
                let isFilled = item.intensity > 0.0 // 只要 > 0 就是打过卡
                RectangleMark(x: .value("Week", item.week), y: .value("Day", item.day), width: .ratio(0.8), height: .ratio(0.8))
                    // 动态光泽：打卡越多颜色越深，悬浮时更亮
                    .foregroundStyle(isFilled ? Color.twIndigo500.opacity(min(1.0, item.intensity + (isHovered ? 0.2 : 0))) : (isDark ? Color.twSlate800 : Color.twSlate100))
                    .cornerRadius(2)
            }
            .chartXAxis(.hidden).chartYAxis(.hidden).chartYScale(domain: .automatic(includesZero: false, reversed: true))
            .opacity(showAnimation ? 1.0 : 0.0)
            .scaleEffect(showAnimation ? (isHovered ? 1.02 : 1.0) : 0.95)
            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: showAnimation)
        }
        .padding(24)
        .homeStaticGlassCardStyle()
        .onHover { h in withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) { isHovered = h } }
        .onAppear {
            processHeatmapData()
            showAnimation = true
        }
        .onChange(of: allRecords) { _, _ in processHeatmapData() }
    }
    
    // ✨ 核心数据清洗逻辑：将记录精确填入 26 周 × 7 天的矩阵中
    private func processHeatmapData() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var tempItems: [HeatmapItem] = []
        
        // 1. 统计每天的打卡次数 (Dictionary 寻址极快)
        var dailyCounts: [Date: Int] = [:]
        for record in allRecords {
            let d = calendar.startOfDay(for: record.date)
            dailyCounts[d, default: 0] += 1
        }
        
        // 2. 生成过去 182 天 (26 周) 的完整空网格，然后将数据塞进去
        // 我们让最右边 (Week 25) 的最下面表示今天，向左和向上追溯。
        let totalDays = 26 * 7 // 182
        
        for daysAgo in (0..<totalDays).reversed() { // 从 181 天前，一直到 0 (今天)
            // 获取那天的日期
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) else { continue }
            
            // 查询那天有没有打卡记录
            let count = dailyCounts[date] ?? 0
            
            // 将倒数天数转换为网格坐标 (让最近的日期落在最右侧的矩阵列)
            let index = 181 - daysAgo // 从 0 递增到 181
            let col = index / 7       // 0 到 25
            let row = index % 7       // 0 到 6
            
            // 计算颜色深度权重 (假设一天打卡 3 次就是深色满值)
            let intensity = count > 0 ? min(Double(count) * 0.35 + 0.3, 1.0) : 0.0
            
            tempItems.append(HeatmapItem(week: col, day: row, intensity: intensity))
        }
        
        self.heatmapData = tempItems
    }
}
