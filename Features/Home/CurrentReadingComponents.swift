import SwiftData
import SwiftUI

// MARK: - 1. 主英雄封面卡

struct HeroBookCard: View {
    let book: Book
    let namespace: Namespace.ID
    @Binding var selectedBook: Book?
    @Binding var activeCoverID: String
    @State private var isHovered = false
    
    var body: some View {
        ZStack(alignment: .leading) {
            // 1. 背景扫光特效 (优化：光泽更柔和)
            GeometryReader { geo in
                Rectangle()
                    .fill(LinearGradient(colors: [.clear, .white.opacity(0.3), .clear], startPoint: .leading, endPoint: .trailing))
                    .frame(width: 120)
                    .rotationEffect(.degrees(20))
                    .offset(x: isHovered ? geo.size.width + 50 : -150)
            }
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            
            HStack(spacing: 24) {
                // 2. 左侧封面与背光
                ZStack {
                    Circle()
                        .fill(Color.twIndigo500.opacity(isHovered ? 0.3 : 0.1))
                        .frame(width: 100, height: 100)
                        .blur(radius: 30)
                        .offset(x: 20, y: 20)
                    
                    if selectedBook?.id != book.id {
                        LocalCoverView(coverData: book.coverData, fallbackTitle: book.title)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .matchedGeometryEffect(id: "hero-\(book.id)", in: namespace)
                            .frame(width: 150, height: 200)
                            // ✨ 封面优化：不仅 3D 旋转，还微微放大靠近镜头，立体感倍增
                            .scaleEffect(isHovered ? 1.05 : 1.0)
                            .rotation3DEffect(.degrees(isHovered ? 12 : 0), axis: (x: 0, y: 1, z: -0.2), perspective: 0.5)
                            .offset(y: isHovered ? -8 : 0)
                            .shadow(color: Color.black.opacity(isHovered ? 0.3 : 0.1), radius: isHovered ? 20 : 8, x: 0, y: isHovered ? 15 : 5)
                    } else {
                        LocalCoverView(coverData: book.coverData, fallbackTitle: book.title)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .frame(width: 110, height: 160)
                            .opacity(0.001)
                    }
                }
                
                // 3. 右侧信息区
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(book.title)
                            .font(.system(size: 26, weight: .black))
                            .foregroundColor(isHovered ? .twIndigo500 : .primary)
                            .lineLimit(2)
                        
                        Text(book.author)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.twSlate500)
                            .lineLimit(1)
                    }
                    // ✨ 核心修复 1：图形级平滑缩放，并以“左侧”为锚点，保证排版不乱
                    .scaleEffect(isHovered ? 1.05 : 1.0, anchor: .leading)
                    // ✨ 核心修复 2：X轴物理平移
                    .offset(x: isHovered ? 10 : 0)
                    // ✨ 核心修复 3：独立挂载 easeInOut 动画！它能拦截上面的文字颜色和缩放变动，彻底消灭色彩过渡的“重影”和“闪烁”！
                    .animation(.easeInOut(duration: 0.25), value: isHovered)
                    
                    Spacer()
                    
                    // 4. 右下角书本装饰 Icon
                    HStack(alignment: .bottom) {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(Color.twIndigo500.opacity(isHovered ? 0.15 : 0))
                                .frame(width: 60, height: 60)
                                .scaleEffect(isHovered ? 1.5 : 1)
                                .blur(radius: 10)
                            
                            Image(systemName: "book.pages.fill")
                                .font(.system(size: 50))
                                .foregroundColor(isHovered ? .twIndigo500 : .twSlate400.opacity(0.3))
                                // ✨ Icon 优化：像失重一样浮起来并轻微倾斜
                                .rotationEffect(.degrees(isHovered ? -12 : 0))
                                .scaleEffect(isHovered ? 1.15 : 1)
                                .offset(y: isHovered ? -5 : 0)
                        }
                    }
                }
                .padding(.vertical, 10)
            }
            .padding(24)
        }
        .contentShape(Rectangle())
        .innerGlassCardStyle(isHovered: isHovered)
        .pointingHand()
        .onHover { hovering in
            // ✨ 核心修复 4：把极端生硬的 interpolatingSpring 换成了柔和且富有呼吸感的普通 spring
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isHovered = hovering
            }
        }
        .onTapGesture {
            activeCoverID = "hero-\(book.id)"
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { selectedBook = book }
        }
    }
}

// MARK: - 2. 进度管理卡片

struct ReadingProgressCard: View {
    @Bindable var book: Book
    @State private var isHovered = false
    @State private var isPulsing = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        let isDark = colorScheme == .dark
        
        ZStack {
            GeometryReader { geo in
                Circle().fill(Color.twFuchsia500.opacity(isHovered ? 0.3 : 0.15)).frame(width: 130, height: 130).blur(radius: 40).position(x: geo.size.width, y: 0)
            }.allowsHitTesting(false)
            
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "target").font(.system(size: 14, weight: .bold))
                    Text("进度记录").font(.system(size: 12, weight: .heavy, design: .rounded)).tracking(1)
                    Spacer()
                }
                .foregroundColor(isHovered ? .twFuchsia500 : .twSlate500)
                .padding(.top, 24).padding(.horizontal, 24)
                
                Spacer()
                
                VStack(spacing: 20) {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(book.progress)").font(.system(size: 64, weight: .black, design: .rounded))
                            .foregroundStyle(isHovered ? AnyShapeStyle(LinearGradient(colors: [.twFuchsia500, .twPurple600], startPoint: .topLeading, endPoint: .bottomTrailing)) : AnyShapeStyle(Color.primary))
                            .contentTransition(.numericText()).animation(.spring(), value: book.progress)
                        Text("%").font(.title3).fontWeight(.black).foregroundColor(isHovered ? .twFuchsia500.opacity(0.6) : .twSlate400)
                    }
                    
                    HStack(spacing: 60) {
                        Button(action: { book.progress = max(0, book.progress - 1) }) {
                            Image(systemName: "minus").font(.system(size: 16, weight: .bold)).foregroundColor(isHovered ? .twFuchsia500 : .twSlate500).frame(width: 36, height: 36).background(Color.primary.opacity(0.05)).clipShape(Circle()).scaleEffect(isHovered ? 1.1 : 1.0)
                        }.buttonStyle(.plain).pointingHand()
                        
                        Button(action: { book.progress = min(100, book.progress + 1) }) {
                            Image(systemName: "plus").font(.system(size: 16, weight: .bold)).foregroundColor(isHovered ? .twFuchsia500 : .twSlate500).frame(width: 36, height: 36).background(Color.primary.opacity(0.05)).clipShape(Circle()).scaleEffect(isHovered ? 1.1 : 1.0)
                        }.buttonStyle(.plain).pointingHand()
                    }
                }
                .padding(.bottom, 45)
            }
            
            GeometryReader { geo in
                VStack {
                    Spacer()
                    ZStack(alignment: .leading) {
                        Rectangle().fill(isDark ? Color.twSlate800.opacity(0.5) : Color.twSlate200.opacity(0.5)).frame(height: 20)
                        Rectangle().fill(LinearGradient(colors: [.twFuchsia500, .twPurple600], startPoint: .leading, endPoint: .trailing))
                            .frame(width: max(0, geo.size.width * CGFloat(book.progress) / 100), height: 20)
                            .overlay(Rectangle().fill(Color.white.opacity(0.6)).frame(width: 6).blur(radius: 2).opacity(isPulsing ? 1.0 : 0.2), alignment: .trailing)
                            .animation(.spring(), value: book.progress)
                    }
                }
            }
        }
        .innerGlassCardStyle(isHovered: isHovered)
        .onHover { h in withAnimation(.spring()) { isHovered = h } }
        .onAppear { withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) { isPulsing = true } }
    }
}

// MARK: - 3. 装饰名言卡片

struct BoomDecorCard: View {
    @State private var isHovered = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        let isDark = colorScheme == .dark
        ZStack(alignment: .leading) {
            if isHovered {
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(LinearGradient(colors: [Color.twIndigo500, Color.twPurple600], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .transition(.opacity)
            }
            
            GeometryReader { geo in
                Rectangle().fill(LinearGradient(colors: [.clear, .white.opacity(0.3), .clear], startPoint: .leading, endPoint: .trailing)).frame(width: 150).rotationEffect(.degrees(15)).offset(x: isHovered ? geo.size.width + 100 : -200)
            }.clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("“读书，是一场随身携带的避难所。”").font(.system(size: 24, weight: .black, design: .serif)).foregroundColor(isHovered ? .white : .primary).scaleEffect(isHovered ? 1.02 : 1.0, anchor: .leading)
                    Text("W.S. MAUGHAM").font(.system(size: 12, weight: .bold, design: .rounded)).tracking(3).foregroundColor(isHovered ? Color.white.opacity(0.8) : .twSlate400)
                }
                Spacer()
                ZStack {
                    Circle().fill(Color.white.opacity(isHovered ? 0.2 : 0)).frame(width: 64, height: 64).blur(radius: 15)
                    Image(systemName: "pencil.and.outline").font(.system(size: 36, weight: .light)).foregroundColor(isHovered ? .white : (isDark ? .twSlate500 : .twSlate400)).scaleEffect(isHovered ? 1.2 : 1.0).rotationEffect(.degrees(isHovered ? -15 : 0))
                }
            }
            .padding(.horizontal, 30).padding(.vertical, 24)
        }
        .frame(height: 120).contentShape(Rectangle())
        .innerGlassCardStyle(isHovered: isHovered)
        .onHover { h in withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { isHovered = h } }
    }
}
