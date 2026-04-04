import SwiftUI
import SwiftData
import Charts

struct KnowledgeSpectrumCard: View {
    @Environment(\.colorScheme) var colorScheme
    // ✨ 接入真实书籍数据 (过滤掉没读过的，让配比更真实)
    @Query(filter: #Predicate<Book> { $0.status != "UNREAD" }) var readBooks: [Book]
    
    @State private var showAnimation = false
    @State private var isHovered = false
    @State private var spectrumData: [SpectrumItem] = []
    
    struct SpectrumItem: Identifiable { let id = UUID(); let name: String; let value: Double; let color: Color }
    // 固定的优美配色池
    let colorPalette: [Color] = [.twPurple500, .twIndigo500, .twTeal600, .twOrange500, .twSky900]
    
    var body: some View {
        let isDark = colorScheme == .dark
        
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("精神食粮配比").font(.system(size: 16, weight: .bold, design: .rounded)).foregroundColor(isDark ? .white : .twSlate800)
                }
                Spacer()
                Image(systemName: "chart.bar.xaxis").foregroundColor(.twPurple500)
            }
            
            VStack(spacing: 12) {
                Spacer(minLength: 0)
                
                if spectrumData.isEmpty {
                    Text("缺乏阅读数据建立图谱").font(.system(size: 12, weight: .bold)).foregroundColor(.twSlate500)
                } else {
                    Chart {
                        ForEach(spectrumData) { item in
                            BarMark(x: .value("Percentage", showAnimation ? item.value : 0), y: .value("Category", "Spectrum"))
                                .foregroundStyle(item.color.gradient)
                        }
                    }
                    .chartXAxis(.hidden).chartYAxis(.hidden)
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
                }
                Spacer(minLength: 0)
            }
        }
        .padding(24)
        .homeStaticGlassCardStyle()
        .onHover { h in withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) { isHovered = h } }
        .onAppear {
            processSpectrumData()
            withAnimation(.easeIn(duration: 0.1)) { showAnimation = true }
        }
        .onChange(of: readBooks) { _, _ in processSpectrumData() }
    }
    
    // ✨ 核心数据清洗逻辑：归类统计与百分比计算
    private func processSpectrumData() {
        var tagCounts: [String: Double] = [:]
        var totalTags: Double = 0.0
        
        for book in readBooks {
            // ⚠️ 假设你的 Book 模型里有 tags 数组。如果是 category 字符串，改为 [book.category] 即可
            let tags = book.tags
            for tag in tags {
                tagCounts[tag, default: 0] += 1
                totalTags += 1
            }
        }
        
        guard totalTags > 0 else {
            self.spectrumData = []
            return
        }
        
        // 排序取前 4 名
        let sortedTags = tagCounts.sorted { $0.value > $1.value }.prefix(4)
        
        var newSpectrum: [SpectrumItem] = []
        for (index, dict) in sortedTags.enumerated() {
            let percentage = (dict.value / totalTags) * 100.0
            newSpectrum.append(SpectrumItem(name: dict.key, value: percentage, color: colorPalette[index % colorPalette.count]))
        }
        self.spectrumData = newSpectrum
    }
}
