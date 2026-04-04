import SwiftUI
import SwiftData
import Charts

struct MomentumChartCard: View {
    @Environment(\.colorScheme) var colorScheme
    // ✨ 接入真实打卡记录
    @Query(sort: \ReadingRecord.date, order: .reverse) var allRecords: [ReadingRecord]
    
    @State private var showAnimation = false
    @State private var isHovered = false
    @State private var chartData: [Double] = Array(repeating: 0.0, count: 30) // 承载清洗后的 30 天数据
    
    var body: some View {
        let isDark = colorScheme == .dark
        let lineColor = Color.twSky500
        
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("阅读动能").font(.system(size: 16, weight: .bold, design: .rounded)).foregroundColor(isDark ? .white : .twSlate800)
                }
                Spacer()
                Image(systemName: "waveform.path.ecg").foregroundColor(lineColor)
            }
            
            Chart {
                ForEach(Array(chartData.enumerated()), id: \.offset) { index, value in
                    LineMark(x: .value("Day", index), y: .value("Value", showAnimation ? value : 0))
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(lineColor)
                        .lineStyle(StrokeStyle(lineWidth: isHovered ? 4 : 3, lineCap: .round, lineJoin: .round))
                    
                    AreaMark(x: .value("Day", index), y: .value("Value", showAnimation ? value : 0))
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(LinearGradient(colors: [lineColor.opacity(isHovered ? 0.6 : 0.3), .clear], startPoint: .top, endPoint: .bottom))
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 1, dash: [4, 4])).foregroundStyle(isDark ? Color.twSlate700 : Color.twSlate200)
                    AxisValueLabel().foregroundStyle(isDark ? Color.twSlate500 : Color.twSlate400)
                }
            }
            // 根据你的最大数据量动态调整 Y 轴，防止图表顶穿天花板
            .chartYScale(domain: 0...(max(10, chartData.max() ?? 10) * 1.2))
        }
        .padding(24)
        .homeStaticGlassCardStyle()
        .onHover { h in withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) { isHovered = h } }
        .onAppear {
            processMomentumData() // 组件出现时清洗数据
            withAnimation(.easeInOut(duration: 0.8)) { showAnimation = true }
        }
        .onChange(of: allRecords) { _, _ in processMomentumData() } // 数据库有更新时重算
    }
    
    // ✨ 核心数据清洗逻辑：将时间戳转化为连续的 30 天数组
    private func processMomentumData() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var tempArray = Array(repeating: 0.0, count: 30)
        
        for record in allRecords {
            let recordDate = calendar.startOfDay(for: record.date)
            let components = calendar.dateComponents([.day], from: recordDate, to: today)
            
            if let daysAgo = components.day, daysAgo >= 0 && daysAgo < 30 {
                // 索引 29 是今天，0 是 29 天前
                let index = 29 - daysAgo
                // 这里加 1 代表一次打卡。如果你的记录里有 `pagesRead`，可以写成 tempArray[index] += record.pagesRead
                tempArray[index] += 10.0 // 乘个权重让图表波动好看点
            }
        }
        self.chartData = tempArray
    }
}
