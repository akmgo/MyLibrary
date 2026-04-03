import SwiftUI

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


#Preview("Light Mode") {
    MonthReadingCard(days: 15)
        .frame(width: 280, height: 180)
        .padding()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    MonthReadingCard(days: 15)
        .frame(width: 280, height: 180)
        .padding()
        .preferredColorScheme(.dark)
        .background(Color.black.ignoresSafeArea())
        
}
