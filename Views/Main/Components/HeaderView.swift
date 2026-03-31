// Views/Main/Components/HomeHeaderView.swift
import SwiftUI

struct HeaderView: View {
    // 🎛️ 调节区
    let titleFontSize: CGFloat = 110      // 对应 text-[7rem]
    let subtitleFontSize: CGFloat = 22    // 对应 text-2xl
    
    var body: some View {
        ZStack {
            // ================= 1. 极度克制的静态背景光晕 =================
            // 左上角 Indigo 光晕
            Circle()
                .fill(Color.indigo.opacity(0.15))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: -200, y: -50)
            
            // 右下角 Fuchsia (紫色) 光晕
            Circle()
                .fill(Color.purple.opacity(0.15))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: 200, y: 50)
            
            // ================= 2. 文字内容区 =================
            VStack(spacing: 40) {
                // 标题区
                Text("图书馆")
                    .font(.system(size: titleFontSize, weight: .black, design: .default))
                    .tracking(-4) // 对应 tracking-tighter (紧凑字距)
                    // ✨ 核心：文字渐变效果 (对应 bg-clip-text bg-gradient-to-r)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color.primary.opacity(0.7), // 对应 slate-700/400
                                Color.indigo,               // 对应 via-indigo-500
                                Color.primary.opacity(0.7)  // 对应 to-slate-700/400
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2) // drop-shadow-sm
                
                // 名言区
                Text("我心里一直都在暗暗设想，天堂应该是图书馆的模样")
                    .font(.system(size: subtitleFontSize, weight: .regular, design: .serif)) // 对应 font-serif
                    .tracking(6) // 对应 tracking-widest (超宽字距，增加高级感)
                    .foregroundColor(.secondary) // 对应 text-slate-600 (自适应明暗模式)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 60) // 对应 mt-20 mb-20
        }
        // 保证整个 Header 充满横向空间并且居中显示
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

// ✨ 独立预览装配环境，完美支持新版 Xcode 预览
#Preview("Light Mode") {
    HeaderView()
        .padding()
        .preferredColorScheme(.light) // 强制浅色模式
}

#Preview("Dark Mode") {
    HeaderView()
        .padding()
        .preferredColorScheme(.dark) // 强制深色模式
        // 在深色模式预览下加一个偏暗的背景，看得更清楚
        .background(Color.black.ignoresSafeArea())
}
