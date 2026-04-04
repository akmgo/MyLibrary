import SwiftUI
import CoreImage

// ✨ 使用 actor 保证并发安全，强制后台运算
public actor CoverColorExtractor {
    public static let shared = CoverColorExtractor()
    
    // 使用纯内存缓存，已经计算过的书直接秒出
    private var colorCache: [String: Color] = [:]
    
    // ✨ 核心修复：在 actor 内部独立生成兜底颜色 (RGB 值等同于 twIndigo500)
    // 这样就不需要去读取主线程的 Color.twIndigo500，完美消除警告！
    private let fallbackColor = Color(red: 99/255, green: 102/255, blue: 241/255)
    
    public func getDominantColor(from data: Data?, id: String) -> Color {
        // 1. 查缓存
        if let cached = colorCache[id] { return cached }
        
        // 2. 无效数据直接返回独立的兜底色
        guard let data = data,
              let nsImage = NSImage(data: data),
              let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return fallbackColor
        }
        
        // 3. 极速算法：压缩成 1x1 像素点提取平均色
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var bitmapData: [UInt8] = [0, 0, 0, 0]
        
        guard let context = CGContext(data: &bitmapData,
                                      width: 1,
                                      height: 1,
                                      bitsPerComponent: 8,
                                      bytesPerRow: 4,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return fallbackColor
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: 1, height: 1))
        
        // 提取 RGB
        let r = Double(bitmapData[0]) / 255.0
        let g = Double(bitmapData[1]) / 255.0
        let b = Double(bitmapData[2]) / 255.0
        
        let extractedColor = Color(red: r, green: g, blue: b)
        
        // 4. 存入缓存
        colorCache[id] = extractedColor
        return extractedColor
    }
}
