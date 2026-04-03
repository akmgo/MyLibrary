import SwiftUI
import AppKit

struct LocalCoverView: View {
    let coverData: Data?
    let fallbackTitle: String
    
    var body: some View {
        Group {
            // ✨ 直接调用 Mac 独占的 NSImage
            if let data = coverData, let platformImage = NSImage(data: data) {
                Image(nsImage: platformImage)
                    .resizable()
            } else {
                ZStack {
                    LinearGradient(
                        colors: fallbackTitle.mockGradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    Text(String(fallbackTitle.prefix(1)))
                        .font(.system(size: 40, weight: .black))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .aspectRatio(contentMode: .fill)
    }
}

extension String {
    var mockGradientColors: [Color] {
        let hash = abs(self.hashValue)
        let colorPalettes: [[Color]] = [
            [.twIndigo500.opacity(0.8), .twPurple600],
            [.twSky400.opacity(0.8), .twBlue600],
            [.orange.opacity(0.8), .red],
            [.twEmerald400.opacity(0.8), .twTeal600],
            [.pink.opacity(0.8), .twFuchsia600]
        ]
        return colorPalettes[hash % colorPalettes.count]
    }
}
