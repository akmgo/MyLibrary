import SwiftUI

struct HeaderView: View {
    let titleFontSize: CGFloat = 110
    let subtitleFontSize: CGFloat = 22
    
    var body: some View {
        ZStack {
            // 极度克制的静态背景光晕
            Circle()
                .fill(Color.indigo.opacity(0.15))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: -200, y: -50)
            
            Circle()
                .fill(Color.purple.opacity(0.15))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: 200, y: 50)
            
            // 文字内容区
            VStack(spacing: 40) {
                Text("图书馆")
                    .font(.system(size: titleFontSize, weight: .black, design: .default))
                    .tracking(-4)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color.primary.opacity(0.7),
                                Color.indigo,
                                Color.primary.opacity(0.7)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
                
                Text("我心里一直都在暗暗设想，天堂应该是图书馆的模样")
                    .font(.system(size: subtitleFontSize, weight: .regular, design: .serif))
                    .tracking(6)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 60)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
