import SwiftUI
import SwiftData
import Charts

struct YearlyHeatmapCard: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var showAnimation = false
    @State private var isHovered = false
    
    struct HeatmapItem: Identifiable { let id = UUID(); let week: Int; let day: Int; let intensity: Double }
    let heatmapData: [HeatmapItem] = {
        var items: [HeatmapItem] = []; for w in 0..<26 { for d in 0..<7 { items.append(HeatmapItem(week: w, day: d, intensity: Double.random(in: 0...1.2))) } }; return items
    }()
    
    var body: some View {
        let isDark = colorScheme == .dark
        
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("打卡密度").font(.system(size: 16, weight: .bold, design: .rounded)).foregroundColor(isDark ? .white : .twSlate800)
                    Text("READING HEATMAP").font(.system(size: 10, weight: .black, design: .rounded)).foregroundColor(.twSlate500).tracking(1)
                }
                Spacer()
                Image(systemName: "square.grid.3x3.fill").foregroundColor(.twIndigo500)
            }
            
            Chart(heatmapData) { item in
                let isFilled = item.intensity > 0.3
                RectangleMark(x: .value("Week", item.week), y: .value("Day", item.day), width: .ratio(0.8), height: .ratio(0.8))
                    // ✨ 内部联动：悬浮时发光度增加
                    .foregroundStyle(isFilled ? Color.twIndigo500.opacity(min(1.0, item.intensity + (isHovered ? 0.2 : 0))) : (isDark ? Color.twSlate800 : Color.twSlate100))
                    .cornerRadius(2)
            }
            .chartXAxis(.hidden).chartYAxis(.hidden).chartYScale(domain: .automatic(includesZero: false, reversed: true))
            .opacity(showAnimation ? 1.0 : 0.0)
            // ✨ 内部联动：整个图表(而非外壳)进行轻微的呼吸放大
            .scaleEffect(showAnimation ? (isHovered ? 1.02 : 1.0) : 0.95)
            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: showAnimation)
        }
        .padding(24)
        .homeStaticGlassCardStyle()
        .onHover { h in withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) { isHovered = h } }
        .onAppear { showAnimation = true }
    }
}
