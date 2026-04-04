import SwiftUI
import AppKit

// ✨ 使用 actor 保证并发安全，且一切运算强制在后台完成
public actor ImageCacheManager {
    public static let shared = ImageCacheManager()
    
    // 🚀 系统级智能缓存池：系统会在内存吃紧时自动清理，永不爆内存
    private let cache: NSCache<NSString, NSImage> = {
        let cache = NSCache<NSString, NSImage>()
        cache.countLimit = 300 // 最多在内存中保留 300 张高清封面
        return cache
    }()
    
    public func getImage(from data: Data?, id: String) async -> NSImage? {
        guard let data = data else { return nil }
        
        // 1. 生成唯一数字指纹：用“书名 + 数据大小”作为唯一 key，避免每次传庞大的 UUID
        let fingerprint = "\(id)-\(data.count)"
        let cacheKey = NSString(string: fingerprint)
        
        // 2. 闪电直出：如果内存里有这张图，直接返回，不经过任何计算！
        if let cachedImage = cache.object(forKey: cacheKey) {
            return cachedImage
        }
        
        // 3. 暴力干活：把 Data 解析成图像是非常吃 CPU 的。我们把它丢进最高优先级的脱离线程！
        let decodedImage = await Task.detached(priority: .userInitiated) {
            // 这一步在后台静默发生，主线程依然保持 120Hz 的滑动
            return NSImage(data: data)
        }.value
        
        // 4. 存入缓存库
        if let image = decodedImage {
            cache.setObject(image, forKey: cacheKey)
        }
        
        return decodedImage
    }
}
