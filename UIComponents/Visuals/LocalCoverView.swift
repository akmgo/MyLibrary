import SwiftUI

struct LocalCoverView: View {
    let coverData: Data?
    let fallbackTitle: String
    
    @Environment(\.colorScheme) var colorScheme
    
    // ✨ 新增两个状态，用于接管异步加载的生命周期
    @State private var loadedImage: NSImage?
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            if let nsImage = loadedImage {
                // 🎬 状态 1：加载成功！使用优雅的透明度渐显特效
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFill()
                    .transition(.opacity.animation(.easeInOut(duration: 0.4)))
            } else if isLoading && coverData != nil {
                // ⏳ 状态 2：解码中。展示高级骨架屏，拒绝空白和卡顿！
                skeletonView
            } else {
                // 📖 状态 3：这本书真的没有封面数据，展示默认排版文字
                fallbackView
            }
        }
        // 🚀 核心魔法：当组件出现或图片数据发生变化时，启动后台并发请求！
        .task(id: coverData) {
            isLoading = true
            // 去我们刚刚写的引擎里拿图片（如果是滑回去的，这里是 0 毫秒瞬间返回）
            let image = await ImageCacheManager.shared.getImage(from: coverData, id: fallbackTitle)
            
            // 拿到图片后，回到主线程更新 UI
            await MainActor.run {
                self.loadedImage = image
                self.isLoading = false
            }
        }
    }
    
    // =======================
    // 视觉子组件：高级骨架屏
    // =======================
    private var skeletonView: some View {
        let isDark = colorScheme == .dark
        return ZStack {
            Rectangle()
                .fill(isDark ? Color.twSlate800.opacity(0.5) : Color.twSlate200.opacity(0.5))
            
            ProgressView()
                .controlSize(.small)
                .opacity(0.4)
        }
    }
    
    // =======================
    // 视觉子组件：无封面占位文字
    // =======================
    private var fallbackView: some View {
        let isDark = colorScheme == .dark
        return ZStack {
            Rectangle()
                .fill(LinearGradient(colors: isDark ? [.twSlate800, .twSlate900] : [.twSlate200, .twSlate300], startPoint: .topLeading, endPoint: .bottomTrailing))
            
            Text(fallbackTitle)
                .font(.system(size: 16, weight: .bold, design: .serif))
                .foregroundColor(isDark ? .twSlate500 : .twSlate400)
                .multilineTextAlignment(.center)
                .padding(12)
        }
    }
}
