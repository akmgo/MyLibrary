import SwiftUI

// ✨ 动态流体光影引擎 (满屏覆盖版)
struct FluidBackgroundView: View {
    var isDark: Bool
    @State private var move = false
    
    var body: some View {
        GeometryReader { geo in
            // 计算屏幕的绝对宽和高
            let w = geo.size.width
            let h = geo.size.height
            
            ZStack {
                (isDark ? Color.twSlate950 : Color.twSlate50).ignoresSafeArea()
                
                // 光团 1：靛紫流光 (加大至 1.2 倍宽，保证填满左上)
                Circle()
                    .fill(LinearGradient(colors: [.twIndigo400, .twPurple500], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .opacity(isDark ? 0.35 : 0.25)
                    .frame(width: w * 1.2, height: w * 1.2)
                    .blur(radius: 150)
                    // ✨ 动画：大幅度斜向漂移
                    .offset(x: move ? -w * 0.1 : w * 0.3, y: move ? -h * 0.2 : h * 0.2)
                
                // 光团 2：天蓝游影 (加大至 1.5 倍宽，覆盖对角线)
                Circle()
                    .fill(LinearGradient(colors: [.twSky300, .twIndigo300], startPoint: .leading, endPoint: .trailing))
                    .opacity(isDark ? 0.3 : 0.2)
                    .frame(width: w * 1.5, height: w * 1.5)
                    .blur(radius: 180)
                    // ✨ 动画：大范围横向潮汐
                    .offset(x: move ? w * 0.4 : -w * 0.2, y: move ? h * 0.3 : -h * 0.1)
                            
                // 光团 3：紫红点缀 (加大至 1 倍宽，填补死角)
                Circle()
                    .fill(Color.twFuchsia400)
                    .opacity(isDark ? 0.2 : 0.15)
                    .frame(width: w * 1.0, height: w * 1.0)
                    .blur(radius: 150)
                    // ✨ 动画：上下沉浮
                    .offset(x: move ? w * 0.1 : w * 0.4, y: move ? -h * 0.1 : h * 0.5)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .onAppear {
            // ✨ 动画时间缩短至 8 秒，让肉眼清晰感知到液体的“流动感”
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                move.toggle()
            }
        }
    }
}
