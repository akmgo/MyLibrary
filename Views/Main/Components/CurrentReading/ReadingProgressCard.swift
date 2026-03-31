import SwiftUI
import SwiftData

struct ReadingProgressCard: View {
    let book: Book
    @State private var progress: Int = 45
    @State private var isHovered = false
    
    // ✨ 新增：用于控制进度条光晕呼吸动画的状态
    @State private var isPulsing = false
    
    // ==========================================
    // 🎛️ 调节参数区
    // ==========================================
    let numberFontSize: CGFloat = 64      // 数字字号大小
    let verticalSpacing: CGFloat = 16     // 数字与下方加减按钮的【上下间距】
    let buttonSpacing: CGFloat = 80       // 加减按钮之间的【左右间距】
    let progressBarHeight: CGFloat = 20   // 底部进度条的高度
    // ==========================================
    
    var body: some View {
        ZStack {
            // ================= 1. 背景层 =================
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(NSColor.controlBackgroundColor).opacity(0.4))
                .background(.regularMaterial)
                // 注意：这里去掉了 clipShape，统一放到整个 ZStack 最外层裁切
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(isHovered ? 0.1 : 0.05), radius: 10, x: 0, y: 5)
            
            // 右上角粉色呼吸灯（加入了悬浮放大联动）
            Circle()
                .fill(Color.pink.opacity(isHovered ? 0.2 : 0.05))
                .frame(width: 100, height: 100)
                .blur(radius: 30)
                .offset(x: 50, y: -50)
                .scaleEffect(isHovered ? 1.2 : 1.0)
            
            // ================= 2. 内容层 =================
            VStack(spacing: 0) { // 去除默认间距，精准控制布局
                // 顶部标题
                HStack {
                    Image(systemName: "target").font(.system(size: 14, weight: .bold))
                    Text("进度记录").font(.system(size: 12, weight: .heavy, design: .rounded)).tracking(1)
                    Spacer()
                }
                .foregroundColor(isHovered ? .pink : .secondary)
                .padding(.top, 20).padding(.horizontal, 20)
                
                Spacer()
                
                // 大数字与加减号
                VStack(spacing: verticalSpacing) {
                    
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(progress)")
                            .font(.system(size: numberFontSize, weight: .black, design: .rounded))
                            // ✨ 恢复炫酷：回归 AnyShapeStyle 的渐变文字特效
                            .foregroundStyle(isHovered ? AnyShapeStyle(LinearGradient(colors: [Color.pink, Color.purple], startPoint: .topLeading, endPoint: .bottomTrailing)) : AnyShapeStyle(Color.primary))
                            // ✨ 恢复炫酷：数字上下滚动跳转动画
                            .contentTransition(.numericText())
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: progress)
                        
                        Text("%").font(.title3).fontWeight(.black).foregroundColor(isHovered ? .pink.opacity(0.6) : .secondary)
                    }
                    
                    HStack(spacing: buttonSpacing) {
                        Button(action: { progress = max(0, progress - 1) }) {
                            Image(systemName: "minus")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(isHovered ? .pink : .secondary)
                                .frame(width: 32, height: 32)
                                .background(Color.primary.opacity(0.05))
                                .clipShape(Circle())
                                .scaleEffect(isHovered ? 1.1 : 1.0) // 悬浮时按钮微微放大
                        }.buttonStyle(.plain)
                        
                        Button(action: { progress = min(100, progress + 1) }) {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(isHovered ? .pink : .secondary)
                                .frame(width: 32, height: 32)
                                .background(Color.primary.opacity(0.05))
                                .clipShape(Circle())
                                .scaleEffect(isHovered ? 1.1 : 1.0)
                        }.buttonStyle(.plain)
                    }
                }
                .padding(.bottom, 20) // 给底部留出呼吸空间
                
                Spacer()
                
                // 底部进度条
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle().fill(Color.primary.opacity(0.05))
                        
                        Rectangle()
                            .fill(LinearGradient(colors: [Color.pink, Color.purple], startPoint: .leading, endPoint: .trailing))
                            .frame(width: max(0, geo.size.width * CGFloat(progress) / 100))
                            .overlay(
                                // ✨ 恢复炫酷：边缘的高光呼吸闪烁特效 (Pulse)
                                Rectangle()
                                    .fill(Color.white.opacity(0.6))
                                    .frame(width: 6)
                                    .blur(radius: 3)
                                    .opacity(isPulsing ? 1.0 : 0.2),
                                alignment: .trailing
                            )
                            // 丝滑拉伸动画
                            .animation(.spring(response: 0.4, dampingFraction: 0.75), value: progress)
                    }
                }
                .frame(height: progressBarHeight)
            }
        }
        // ✨ 重点优化：将裁切提到最外层！
        // 这样底部的直角进度条，就会被完美切出卡片相同的圆润边角！
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .onHover { hovering in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { isHovered = hovering }
        }
        .onAppear {
            // 启动进度条的呼吸循环动画
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}

// ===============================================
// 预览装配（请确保项目里已经有刚才写的 PreviewData.swift）
// ===============================================
#Preview("Light Mode") {
    ReadingProgressCard(book: PreviewData.mockBook)
        .frame(width: 180, height: 200)
        .padding()
        .preferredColorScheme(.light)
        .modelContainer(PreviewData.shared)
}

#Preview("Dark Mode") {
    ReadingProgressCard(book: PreviewData.mockBook)
        .frame(width: 180, height: 200)
        .padding()
        .preferredColorScheme(.dark)
        .background(Color.black.ignoresSafeArea())
        .modelContainer(PreviewData.shared)
}
