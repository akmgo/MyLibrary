import SwiftUI
import SwiftData
import Charts

struct KnowledgeSpectrumCard: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var showAnimation = false
    @State private var isHovered = false
    
    struct SpectrumItem: Identifiable { let id = UUID(); let name: String; let value: Double; let color: Color }
    let spectrumData: [SpectrumItem] = [
        SpectrumItem(name: "玄幻史诗", value: 40.0, color: .twPurple500), SpectrumItem(name: "近代历史", value: 25.0, color: .twIndigo500),
        SpectrumItem(name: "前沿技术", value: 20.0, color: .twTeal600), SpectrumItem(name: "商业基金", value: 15.0, color: .twOrange500)
    ]
    
    var body: some View {
        let isDark = colorScheme == .dark
        
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("精神食粮配比").font(.system(size: 16, weight: .bold, design: .rounded)).foregroundColor(isDark ? .white : .twSlate800)
                    Text("KNOWLEDGE SPECTRUM").font(.system(size: 10, weight: .black, design: .rounded)).foregroundColor(.twSlate500).tracking(1)
                }
                Spacer()
                Image(systemName: "chart.bar.xaxis").foregroundColor(.twPurple500)
            }
            
            VStack(spacing: 12) {
                Spacer(minLength: 0)
                Chart {
                    ForEach(spectrumData) { item in
                        BarMark(x: .value("Percentage", showAnimation ? item.value : 0), y: .value("Category", "Spectrum"))
                            .foregroundStyle(item.color.gradient)
                    }
                }
                .chartXAxis(.hidden).chartYAxis(.hidden)
                // ✨ 内部联动：悬浮时流体进度条瞬间变粗 (16 -> 24)
                .frame(height: isHovered ? 24 : 16)
                .chartPlotStyle { plotArea in plotArea.clipShape(Capsule()) }
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isHovered)
                .animation(.spring(response: 0.8, dampingFraction: 0.75), value: showAnimation)
                
                HStack {
                    ForEach(spectrumData) { item in
                        HStack(spacing: 4) {
                            Circle().fill(item.color).frame(width: 8, height: 8)
                            Text(item.name).font(.system(size: 11, weight: .bold)).foregroundColor(isDark ? .twSlate300 : .twSlate600)
                            Text("\(Int(item.value))%").font(.system(size: 10, weight: .medium)).foregroundColor(.twSlate500)
                        }
                        Spacer()
                    }
                }
                .opacity(showAnimation ? 1 : 0)
                .animation(.easeIn(duration: 0.5).delay(0.3), value: showAnimation)
                Spacer(minLength: 0)
            }
        }
        .padding(24)
        .homeStaticGlassCardStyle()
        .onHover { h in withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) { isHovered = h } }
        .onAppear { showAnimation = true }
    }
}
