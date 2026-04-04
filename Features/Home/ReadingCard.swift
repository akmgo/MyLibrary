import Charts
import SwiftData
import SwiftUI

// MARK: - 🏆 终极版：全息联动在读卡片 (三分布局视觉深度优化版)

struct ReadingCard: View {
    let book: Book
    let progress: Double
    let isDark: Bool
    
    // ✨ 路由参数
    let namespace: Namespace.ID
    @Binding var selectedBook: Book?
    @Binding var activeCoverID: String
    
    @State private var isHovered = false
    @State private var ambientColor: Color = .twIndigo500
    @State private var accentColor: Color = .twSky500
    @State private var animatedProgress: Double = 0.0
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                // 2. ✨ 核心内容区：三分网格布局 (视觉深度优化)
                HStack(spacing: 24) {
                    
                    // ================= 👈 第一区：悬浮封面 (占比约 25%) =================
                    ZStack {
                        if selectedBook?.id != book.id {
                            LocalCoverView(coverData: book.coverData, fallbackTitle: book.title)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .matchedGeometryEffect(id: "hero-\(book.id)", in: namespace)
                                .frame(width: 120, height: 180)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.2), lineWidth: 1))
                                .shadow(color: ambientColor.opacity(0.2), radius: 8, y: 4)
                                .scaleEffect(isHovered ? 1.04 : 1.0)
                                .animation(.easeInOut(duration: 0.35), value: isHovered)
                        } else {
                            LocalCoverView(coverData: book.coverData, fallbackTitle: book.title)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .frame(width: 120, height: 180)
                                .opacity(0.001)
                        }
                    }
                    
                    // ================= 👆 ✨ 第二区：信息与图库 (居中+清洗，占比约 40%) =================
                    VStack(alignment: .center, spacing: 16) { // ✨ 彻底改为居中对齐，增加间距
                        
                        // ✨ 顶部信息：增加更大的顶边距和文字居中
                        VStack(alignment: .center, spacing: 6) { // ✨ 内部居中
                            Text(book.title)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(isDark ? .white : .twSlate800)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            
                            HStack(spacing: 6) {
                                // 增加一个精致的小点缀，平衡视觉
                                Image(systemName: "sparkles")
                                    .font(.system(size: 12))
                                    .foregroundColor(accentColor.opacity(0.8))
                                
                                Text(book.author)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(isDark ? .twSlate400 : .twSlate500)
                                    .lineLimit(1)
                            }
                        }
                        .padding(.top, 10) // ✨ 核心修复：单独设置更大的顶边距
                        
                        // ✨ 底部 library.png：彻底清洗， scaledToFit 完整显示
                        Image("library")
                            .resizable()
                            .scaledToFit() // ✨ 核心修复：彻底解决显示不全，完整缩放
                            .frame(height: 100) // 控制高度
                            .frame(maxWidth: .infinity)
//                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 12, style: .continuous)
//                                    .stroke(isDark ? Color.white.opacity(0.15) : Color.black.opacity(0.05), lineWidth: 1)
//                            )
                            // 悬浮联动，只做透明度和边框颜色的物理感
                            .shadow(color: accentColor.opacity(isHovered ? 0.1 : 0), radius: 6)
                            .opacity(isHovered ? 1.0 : 0.8) // 悬浮时完全显现
                    }
                    .frame(maxWidth: .infinity, alignment: .center) // 确保父容器居中
                    
                    // ================= 👉 ✨ 第三区：巨型圆环 (清晰度提升，占比约 35%) =================
                    ZStack {
                        // 1. 底层微光晕，烘托巨大圆环的质感
                        Circle()
                            .fill(accentColor.opacity(isDark ? 0.1 : 0.05))
                            .frame(width: 170, height: 170)
                            .blur(radius: 12)
                            .scaleEffect(isHovered ? 1.05 : 1.0)
                        
                        // 2. 核心图表：尺寸飙升到 150，压迫感和精致度拉满
                        Chart {
                            SectorMark(angle: .value("Done", animatedProgress), innerRadius: .ratio(0.85), angularInset: 1.5)
                                .foregroundStyle(accentColor.gradient).cornerRadius(4)
                            
                            // ✨ 核心修复：大幅增加灰色轨迹的颜色深度和不透明度，让轮廓极度清晰
                            SectorMark(angle: .value("Left", 100 - animatedProgress), innerRadius: .ratio(0.85), angularInset: 1.5)
                                .foregroundStyle(isDark ? Color.twSlate600.opacity(0.8) : Color.twSlate300.opacity(0.8)) // ✨ 大幅提升清晰度
                                .cornerRadius(4)
                        }
                        .frame(width: 150, height: 150)
                        // 为圆环增加一个非常弱的、随主题色变的内阴影感，提升质感
                        .overlay(
                            Circle()
                                .stroke(isHovered ? accentColor.opacity(0.3) : .clear, lineWidth: 2)
                                .blur(radius: 1)
                        )
                        .shadow(color: accentColor.opacity(isHovered ? 0.4 : 0.0), radius: 10)
                        
                        // 3. 中央数据百分比
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            Text("\(Int(progress))").font(.system(size: 32, weight: .heavy, design: .rounded))
                            Text("%").font(.system(size: 16, weight: .bold)).opacity(0.8)
                        }
                        .foregroundColor(isHovered ? accentColor : (isDark ? .white : .twSlate800))
                        .animation(.easeInOut(duration: 0.2), value: isHovered)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 16)
            }
            .frame(maxHeight: .infinity)
            
            // ================= 底部：线性能量条 =================
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle().fill(isDark ? Color.twSlate800.opacity(0.3) : Color.twSlate200.opacity(0.3))
                    Rectangle().fill(LinearGradient(colors: [accentColor.opacity(0.4), accentColor, accentColor.opacity(0.7)], startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * CGFloat(animatedProgress / 100.0))
                        // 增加进度条尖端的发光点
                        .overlay(
                            Rectangle().fill(Color.white).frame(width: 2).blur(radius: 1),
                            alignment: .trailing
                        )
                }
            }.frame(height: 6)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .homeStaticGlassCardStyle()
        .contentShape(Rectangle())
        .pointingHand()
        // ✨ 原汁原味的点击触发
        .onTapGesture {
            activeCoverID = "hero-\(book.id)"
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { selectedBook = book }
        }
        .onAppear { animatedProgress = progress }
        .onHover { h in
            isHovered = h
            if h {
                withAnimation(nil) { animatedProgress = 0 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.75)) { animatedProgress = progress }
                }
            } else {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { animatedProgress = progress }
            }
        }
        .task(id: book.id) {
            let mainColor = await CoverColorExtractor.shared.getDominantColor(from: book.coverData, id: book.id)
            let compColor = generateSubtleComplementary(from: mainColor)
            withAnimation(.easeInOut(duration: 0.5)) { self.ambientColor = mainColor; self.accentColor = compColor }
        }
    }
    
    private func generateSubtleComplementary(from color: Color) -> Color {
        guard let nsColor = NSColor(color).usingColorSpace(.deviceRGB) else { return color }
        var hue: CGFloat = 0, sat: CGFloat = 0, bri: CGFloat = 0, alpha: CGFloat = 0
        nsColor.getHue(&hue, saturation: &sat, brightness: &bri, alpha: &alpha)
        let complementaryHue = fmod(hue + 0.5, 1.0)
        let elegantSaturation = min(max(sat, 0.4), 0.7)
        let elegantBrightness = min(max(bri, 0.4), 0.7)
        return Color(nsColor: NSColor(calibratedHue: complementaryHue, saturation: elegantSaturation, brightness: elegantBrightness, alpha: alpha))
    }
}
