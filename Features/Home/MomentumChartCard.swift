import SwiftUI
import SwiftData
import Charts

struct MomentumChartCard: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var showAnimation = false
    @State private var isHovered = false
    
    let data: [Double] = [12, 15, 8, 22, 45, 30, 10, 5, 28, 55, 60, 40, 20, 35]
    
    var body: some View {
        let isDark = colorScheme == .dark
        let lineColor = Color.twSky500
        
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("阅读动能").font(.system(size: 16, weight: .bold, design: .rounded)).foregroundColor(isDark ? .white : .twSlate800)
                    Text("30-DAY MOMENTUM").font(.system(size: 10, weight: .black, design: .rounded)).foregroundColor(.twSlate500).tracking(1)
                }
                Spacer()
                Image(systemName: "waveform.path.ecg").foregroundColor(lineColor)
            }
            
            Chart {
                ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                    LineMark(x: .value("Day", index), y: .value("Value", showAnimation ? value : 0))
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(lineColor)
                        .lineStyle(StrokeStyle(lineWidth: isHovered ? 4 : 3, lineCap: .round, lineJoin: .round)) // ✨ 内部联动：悬浮线条变粗
                    
                    AreaMark(x: .value("Day", index), y: .value("Value", showAnimation ? value : 0))
                        .interpolationMethod(.catmullRom)
                        // ✨ 内部联动：悬浮时面积图变亮
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
        }
        .padding(24)
        .homeStaticGlassCardStyle()
        .onHover { h in withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) { isHovered = h } }
        .onAppear { withAnimation(.easeInOut(duration: 0.8)) { showAnimation = true } }
    }
}
