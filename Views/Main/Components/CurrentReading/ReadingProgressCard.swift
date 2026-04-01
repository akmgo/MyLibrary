import SwiftUI
import SwiftData

struct ReadingProgressCard: View {
    let book: Book
    @State private var progress: Int = 45
    @State private var isHovered = false
    @State private var isPulsing = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        let isDark = colorScheme == .dark
        
        ZStack {
            GeometryReader { geo in
                Circle().fill(Color.twFuchsia500.opacity(isHovered ? 0.3 : 0.15)).frame(width: 130, height: 130).blur(radius: 40).position(x: geo.size.width, y: 0)
            }.allowsHitTesting(false)
            
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "target").font(.system(size: 14, weight: .bold))
                    Text("进度记录").font(.system(size: 12, weight: .heavy, design: .rounded)).tracking(1)
                    Spacer()
                }
                .foregroundColor(isHovered ? .twFuchsia500 : .twSlate500)
                .padding(.top, 24).padding(.horizontal, 24)
                
                Spacer()
                
                VStack(spacing: 20) {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(progress)").font(.system(size: 64, weight: .black, design: .rounded))
                            .foregroundStyle(isHovered ? AnyShapeStyle(LinearGradient(colors: [.twFuchsia500, .twPurple600], startPoint: .topLeading, endPoint: .bottomTrailing)) : AnyShapeStyle(Color.primary))
                            .contentTransition(.numericText()).animation(.spring(), value: progress)
                        Text("%").font(.title3).fontWeight(.black).foregroundColor(isHovered ? .twFuchsia500.opacity(0.6) : .twSlate400)
                    }
                    
                    HStack(spacing: 60) {
                        Button(action: { progress = max(0, progress - 1) }) { Image(systemName: "minus").font(.system(size: 16, weight: .bold)).foregroundColor(isHovered ? .twFuchsia500 : .twSlate500).frame(width: 36, height: 36).background(Color.primary.opacity(0.05)).clipShape(Circle()).scaleEffect(isHovered ? 1.1 : 1.0) }.buttonStyle(.plain)
                        Button(action: { progress = min(100, progress + 1) }) { Image(systemName: "plus").font(.system(size: 16, weight: .bold)).foregroundColor(isHovered ? .twFuchsia500 : .twSlate500).frame(width: 36, height: 36).background(Color.primary.opacity(0.05)).clipShape(Circle()).scaleEffect(isHovered ? 1.1 : 1.0) }.buttonStyle(.plain)
                    }
                }
                .padding(.bottom, 45)
            }
            
            GeometryReader { geo in
                VStack {
                    Spacer()
                    ZStack(alignment: .leading) {
                        Rectangle().fill(isDark ? Color.twSlate800.opacity(0.5) : Color.twSlate200.opacity(0.5)).frame(height: 20)
                        Rectangle().fill(LinearGradient(colors: [.twFuchsia500, .twPurple600], startPoint: .leading, endPoint: .trailing)).frame(width: max(0, geo.size.width * CGFloat(progress) / 100), height: 20)
                            .overlay(Rectangle().fill(Color.white.opacity(0.6)).frame(width: 6).blur(radius: 2).opacity(isPulsing ? 1.0 : 0.2), alignment: .trailing)
                            .animation(.spring(), value: progress)
                    }
                }
            }
        }
        .innerGlassCardStyle(isHovered: isHovered)
        .onHover { h in withAnimation(.spring()) { isHovered = h } }
        .onAppear { withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) { isPulsing = true } }
    }
}

// ===============================================
// 预览装配（请确保项目里已经有刚才写的 PreviewData.swift）
// ===============================================
#Preview("Light Mode") {
    ReadingProgressCard(book: PreviewData.mockBook)
        .frame(width: 180, height: 200)
        .padding()
        .preferredColorScheme(.light)
        .modelContainer(PreviewData.shared)
}

#Preview("Dark Mode") {
    ReadingProgressCard(book: PreviewData.mockBook)
        .frame(width: 180, height: 200)
        .padding()
        .preferredColorScheme(.dark)
        .background(Color.black.ignoresSafeArea())
        .modelContainer(PreviewData.shared)
}
