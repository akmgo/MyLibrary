import SwiftUI
import AppKit
import ImageIO

// ✨ 商业级图片内存池
class ImageCache {
    static let shared: NSCache<NSString, NSImage> = {
        let cache = NSCache<NSString, NSImage>()
        cache.countLimit = 300 // 缓存数量上限
        cache.totalCostLimit = 1024 * 1024 * 150 // 约 150MB 内存上限
        return cache
    }()
}

struct LocalCoverView: View {
    let coverData: Data?
    let fallbackTitle: String
    let cacheKey: String
    
    // 内部状态
    @State private var loadedImage: NSImage?
    
    // ✨ 核心魔法：自定义初始化器
    init(coverData: Data?, fallbackTitle: String) {
        self.coverData = coverData
        self.fallbackTitle = fallbackTitle
        
        // 🚀 性能革命：用数据的字节长度作为 Key，瞬间完成，彻底消灭 hashValue 带来的主线程卡顿！
        let key = coverData != nil ? "\(coverData!.count)" : "empty"
        self.cacheKey = key
        
        // ✨ 动画修复革命：在视图被创建的瞬间，同步检查缓存！
        // 如果命中缓存，图片直接就位，绝对不会发生“从占位符变成图片”的状态突变，英雄动画完美衔接，再无闪烁！
        if let cached = ImageCache.shared.object(forKey: key as NSString) {
            self._loadedImage = State(initialValue: cached)
        } else {
            self._loadedImage = State(initialValue: nil)
        }
    }
    
    var body: some View {
        Group {
            if let img = loadedImage {
                // 命中加载
                Image(nsImage: img)
                    .resizable()
            } else if coverData != nil {
                // 首次加载时的极简占位（只会在你刚打开 App 的第一秒看到，之后全被缓存）
                Rectangle().fill(Color.gray.opacity(0.1))
            } else {
                // 兜底文字渐变封面
                ZStack {
                    LinearGradient(colors: fallbackTitle.mockGradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                    Text(String(fallbackTitle.prefix(1))).font(.system(size: 40, weight: .black)).foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .aspectRatio(contentMode: .fill)
        // 使用 task 代替 onAppear，当用户飞速滑动错过这张卡片时，任务会被瞬间自动取消，不浪费一丝性能
        .task(id: cacheKey) {
            if loadedImage == nil {
                await processImage()
            }
        }
    }
    
    private func processImage() async {
        guard let data = coverData else { return }
        let key = cacheKey as NSString
        
        // 扔到独立后台线程处理，彻底解放主线程
        let compressedImage = await Task.detached(priority: .userInitiated) { () -> NSImage? in
            let options: [CFString: Any] = [kCGImageSourceShouldCache: false]
            guard let source = CGImageSourceCreateWithData(data as CFData, options as CFDictionary) else { return nil }
            
            let downsampleOptions: [CFString: Any] = [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                // ✨ 画质回归：提升到 800px。在 Retina 屏幕上绝对清晰，同时体积依然极小！
                kCGImageSourceThumbnailMaxPixelSize: 800
            ]
            
            guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, downsampleOptions as CFDictionary) else { return nil }
            return NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
        }.value
        
        // 如果任务已被取消（滑出屏幕），直接丢弃，不渲染
        if Task.isCancelled { return }
        
        if let finalImage = compressedImage {
            ImageCache.shared.setObject(finalImage, forKey: key)
            // 切回主线程更新
            await MainActor.run {
                // ✨ 注意：这里坚决不加 withAnimation！
                // 加上动画会干扰 matchedGeometryEffect，导致飞行降落时抖动
                self.loadedImage = finalImage
            }
        }
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
