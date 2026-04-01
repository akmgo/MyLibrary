import SwiftUI

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


#Preview("Light Mode") {
    YearReadingCard(count: 24)
        .frame(width: 280, height: 180)
        .padding()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    YearReadingCard(count: 24)
        .frame(width: 280, height: 180)
        .padding()
        .preferredColorScheme(.dark)
        .background(Color.black.ignoresSafeArea())
        
}
