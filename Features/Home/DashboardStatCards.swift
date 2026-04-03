import SwiftUI

// MARK: - 1. 年度统计卡片
struct YearReadingCard: View {
    let count: Int
    @State private var isHovered = false

    var body: some View {
        ZStack(alignment: .leading) {
            GridLineShape()
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                .mask(RadialGradient(colors: [.black, .clear], center: .center, startRadius: 0, endRadius: 200))

            GeometryReader { geo in
                Circle().fill(Color.twIndigo500.opacity(0.3)).frame(width: 160, height: 160).blur(radius: 50).position(x: geo.size.width + 40, y: geo.size.height + 40)
            }.allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 8) {
                    Image(systemName: "book.fill").font(.system(size: 14, weight: .bold))
                    Text("今年已读").font(.system(size: 13, weight: .bold)).tracking(2)
                }.foregroundColor(.twIndigo600)

                Spacer()

                HStack(alignment: .bottom, spacing: 6) {
                    Text("\(count)").font(.system(size: 72, weight: .black, design: .rounded))
                        .foregroundStyle(LinearGradient(colors: [.primary, .twIndigo500], startPoint: .top, endPoint: .bottom))
                        .shadow(color: Color.twIndigo500.opacity(isHovered ? 0.4 : 0), radius: 15, x: 0, y: 10)
                    Text("本").font(.system(size: 18, weight: .black)).foregroundColor(.twIndigo500.opacity(0.6)).padding(.bottom, 15)
                }
                .frame(maxWidth: .infinity, alignment: .center).scaleEffect(isHovered ? 1.05 : 1.0)

                Spacer()
            }
            .padding(24)
        }
        .innerGlassCardStyle(isHovered: isHovered)
        .onHover { h in withAnimation(.spring()) { isHovered = h } }
    }
}

// MARK: - 2. 月度统计卡片
struct MonthReadingCard: View {
    let days: Int
    @State private var isHovered = false

    var body: some View {
        ZStack(alignment: .leading) {
            GridDotShape()
                .fill(Color.twEmerald500.opacity(0.2))
                .mask(RadialGradient(colors: [.black, .clear], center: .center, startRadius: 0, endRadius: 180))

            GeometryReader { geo in
                Circle().fill(Color.twEmerald500.opacity(0.3)).frame(width: 160, height: 160).blur(radius: 50).position(x: -40, y: -40)
            }.allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 8) {
                    Image(systemName: "calendar").font(.system(size: 14, weight: .bold))
                    Text("本月共鸣").font(.system(size: 13, weight: .bold)).tracking(2)
                }.foregroundColor(.twEmerald500)

                Spacer()

                HStack(alignment: .bottom, spacing: 6) {
                    Text("\(days)").font(.system(size: 72, weight: .black, design: .rounded))
                        .foregroundStyle(LinearGradient(colors: [.primary, .twEmerald500], startPoint: .top, endPoint: .bottom))
                        .shadow(color: Color.twEmerald500.opacity(isHovered ? 0.4 : 0), radius: 15, x: 0, y: 10)
                    Text("天").font(.system(size: 18, weight: .black)).foregroundColor(.twEmerald500.opacity(0.6)).padding(.bottom, 15)
                }
                .frame(maxWidth: .infinity, alignment: .center).scaleEffect(isHovered ? 1.05 : 1.0)

                Spacer()
            }
            .padding(24)
        }
        .innerGlassCardStyle(isHovered: isHovered)
        .onHover { h in withAnimation(.spring()) { isHovered = h } }
    }
}

// MARK: - 3. 周度能量矩阵
struct WeeklyEnergyMatrix: View {
    let continuousDays: Int
    let weekData: [Bool]
    let todayIndex: Int
    let days = ["一", "二", "三", "四", "五", "六", "日"]
    
    @State private var isHovered = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        let isDark = colorScheme == .dark
        
        ZStack(alignment: .leading) {
            LinearGradient(colors: [Color.twSky500.opacity(0.05), .clear], startPoint: .top, endPoint: .bottom)
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            
            VStack(spacing: 20) {
                HStack {
                    Label("本周能量矩阵", systemImage: "sparkles").font(.system(size: 14, weight: .bold)).foregroundColor(isDark ? .twSky400 : .twSky600).tracking(1)
                    Spacer()
                    HStack(spacing: 6) {
                        Circle().fill(Color.twSky500).frame(width: 6, height: 6).shadow(color: .twSky500, radius: 4)
                        Text("已充能 \(continuousDays)/7").font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(isDark ? .twSky300 : .twSky700)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Color.twSky500.opacity(0.1))
                    .overlay(Capsule().stroke(Color.twSky500.opacity(0.2), lineWidth: 1))
                    .clipShape(Capsule())
                }
                
                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { index in
                        let isToday = index == todayIndex
                        let isActive = weekData[index]
                        
                        VStack(spacing: 12) {
                            Text(days[index]).font(.system(size: 12, weight: .black)).foregroundColor(isToday ? (isActive ? .twSky500 : .twOrange500) : (isDark ? .twSlate500 : .twSlate400))
                            EnergyBlock(isActive: isActive, isToday: isToday)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 24)
        }
        .innerGlassCardStyle(isHovered: isHovered)
        .onHover { h in withAnimation(.spring()) { isHovered = h } }
    }
}

// 专属私有组件：能量块
private struct EnergyBlock: View {
    let isActive: Bool
    let isToday: Bool
    @Environment(\.colorScheme) var colorScheme
    @State private var isPulsing = false
    
    var body: some View {
        let isDark = colorScheme == .dark
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(isActive ? AnyShapeStyle(LinearGradient(colors: [isDark ? Color.twSky500 : Color.twSky400, isDark ? Color.twSky700 : Color.twSky600], startPoint: .top, endPoint: .bottom)) : (isToday ? AnyShapeStyle(isDark ? Color.twSlate800 : Color.twSlate100) : AnyShapeStyle(isDark ? Color.twSlate800.opacity(0.5) : Color.twSlate200.opacity(0.5))))
            
            if isActive {
                RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(isDark ? Color.twSky400.opacity(0.5) : Color.twSky300, lineWidth: 1)
            } else if isToday {
                RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color.twOrange500.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
            } else {
                RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(isDark ? Color.white.opacity(0.05) : Color.twSlate300.opacity(0.5), lineWidth: 1)
            }
            
            if isActive {
                VStack {
                    Capsule().fill(Color.white.opacity(0.5)).frame(width: 16, height: 4).blur(radius: 1).padding(.top, 2)
                    Spacer()
                }
            }
            
            Circle().fill(isActive ? Color.white : (isToday ? Color.twOrange500 : (isDark ? Color.twSlate600 : Color.twSlate300)))
                .frame(width: isActive ? 10 : 8, height: isActive ? 10 : 8)
                .shadow(color: isActive ? .white : (isToday ? .twOrange500 : .clear), radius: isActive ? 6 : (isToday ? 5 : 0))
                .opacity(isToday && !isActive ? (isPulsing ? 1.0 : 0.4) : 1.0)
        }
        .frame(width: 44, height: 48)
        .shadow(color: isActive ? Color.twSky500.opacity(0.4) : .clear, radius: 8, x: 0, y: 5)
        .scaleEffect(isActive ? 1.05 : 1.0)
        .onAppear { if isToday && !isActive { withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) { isPulsing = true } } }
    }
}
