import SwiftUI
import SwiftData
import Charts

struct ResonanceWaveChart: View {
    @Environment(\.colorScheme) var colorScheme
    @Query var allExcerpts: [Excerpt]
    
    @State private var currentIndex: Int = 0
    @State private var wavePhase: Double = 0.0
    @State private var isHovered = false
    
    var body: some View {
        let isDark = colorScheme == .dark
        let currentExcerpt = allExcerpts.isEmpty ? .init(content: "思想的留白，去阅读中遇见自己。", createdAt: Date()) : allExcerpts[currentIndex]
        
        Chart {
            ForEach(0..<30, id: \.self) { index in
                let x = Double(index)
                // ✨ 内部联动：悬浮时波浪振幅微微变大
                let y = sin(x * 0.3 + wavePhase) * (isHovered ? 18 : 15) + 30
                
                AreaMark(x: .value("X", x), y: .value("Y", y))
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(LinearGradient(colors: [Color.twIndigo500.opacity(isDark ? (isHovered ? 0.5 : 0.3) : 0.15), .clear], startPoint: .bottom, endPoint: .top))
                
                LineMark(x: .value("X", x), y: .value("Y", y))
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(Color.twIndigo500.opacity(isHovered ? 0.8 : 0.5))
                    .lineStyle(StrokeStyle(lineWidth: isHovered ? 3 : 2)) // ✨ 内部联动：线条加粗
            }
        }
        .chartXAxis(.hidden).chartYAxis(.hidden)
        .chartYScale(domain: 0...100)
        .chartOverlay { proxy in
            GeometryReader { geo in
                VStack(alignment: .leading, spacing: 16) {
                    Image(systemName: "quote.opening").font(.system(size: 24, weight: .black)).foregroundColor(.twIndigo500.opacity(0.6))
                    Text(currentExcerpt.content).font(.system(size: 18, weight: .bold, design: .serif)).lineSpacing(6).foregroundColor(isDark ? .white : .twSlate800).multilineTextAlignment(.leading).lineLimit(4)
                        .id(currentIndex).transition(.opacity.combined(with: .blurReplace))
                    HStack {
                        Text("— \(currentExcerpt.book?.title ?? "阅读笔记")").font(.system(size: 12, weight: .bold, design: .rounded)).foregroundColor(.twSlate500)
                        Spacer()
                    }
                }.padding(30)
            }
        }
        .background(isDark ? Color.twSlate900.opacity(0.6) : Color.white.opacity(0.8)).background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .onHover { h in withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) { isHovered = h } }
        .onTapGesture { withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { if !allExcerpts.isEmpty { currentIndex = (currentIndex + 1) % allExcerpts.count } } }
        .onAppear { withAnimation(.linear(duration: 5.0).repeatForever(autoreverses: false)) { wavePhase = .pi * 2 } }
    }
}
