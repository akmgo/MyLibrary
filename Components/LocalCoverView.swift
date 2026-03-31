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
                    LinearGradient(colors: [.indigo.opacity(0.4), .purple.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    Text(String(fallbackTitle.prefix(1)))
                        .font(.system(size: 40, weight: .black))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
        }
        .aspectRatio(contentMode: .fill)
    }
}

// ✨ 新增：预览缺失图片时的默认排版
#Preview {
    HStack(spacing: 20) {
        LocalCoverView(coverData: nil, fallbackTitle: "悉达多")
            .frame(width: 120, height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
        LocalCoverView(coverData: nil, fallbackTitle: "Macbeth")
            .frame(width: 120, height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    .padding()
}
