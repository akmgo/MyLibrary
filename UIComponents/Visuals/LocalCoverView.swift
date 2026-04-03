import SwiftUI

#if os(macOS)
import AppKit
typealias PlatformImage = NSImage
#else
import UIKit
typealias PlatformImage = UIImage
#endif

struct LocalCoverView: View {
    let coverData: Data?
    let fallbackTitle: String
    
    var body: some View {
        Group {
            if let data = coverData, let platformImage = PlatformImage(data: data) {
                #if os(macOS)
                Image(nsImage: platformImage).resizable()
                #else
                Image(uiImage: platformImage).resizable()
                #endif
            } else {
                ZStack {
                    // ✨ 魔法：根据书名生成不同的绝美渐变色
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

// ✨ 为 String 添加扩展，根据文字计算固定的渐变色组合
extension String {
    var mockGradientColors: [Color] {
        let hash = abs(self.hashValue)
        let colorPalettes: [[Color]] = [
            [.indigo.opacity(0.6), .purple.opacity(0.8)],
            [.blue.opacity(0.6), .cyan.opacity(0.8)],
            [.orange.opacity(0.6), .red.opacity(0.8)],
            [.green.opacity(0.6), .mint.opacity(0.8)],
            [.pink.opacity(0.6), .orange.opacity(0.8)]
        ]
        return colorPalettes[hash % colorPalettes.count]
    }
}

#Preview("占位封面测试") {
    HStack(spacing: 20) {
        LocalCoverView(coverData: nil, fallbackTitle: "悉达多")
            .frame(width: 120, height: 180).clipShape(RoundedRectangle(cornerRadius: 12))
        LocalCoverView(coverData: nil, fallbackTitle: "百年孤独")
            .frame(width: 120, height: 180).clipShape(RoundedRectangle(cornerRadius: 12))
        LocalCoverView(coverData: nil, fallbackTitle: "三体")
            .frame(width: 120, height: 180).clipShape(RoundedRectangle(cornerRadius: 12))
    }
    .padding()
}
