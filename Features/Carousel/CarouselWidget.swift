import AppKit
import SwiftData
import SwiftUI

struct CarouselWidget: View {
    @Query var books: [Book]
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var currentIndex: Int = 0
    @State private var isScrolling = false
    @State private var isHoveringCenter = false
    @State private var scrollEventMonitor: Any?
    
    var body: some View {
        let isDark = colorScheme == .dark
        
        Group {
            if books.isEmpty {
                Text("暂无书籍，去主页录入第一本吧")
                    .foregroundColor(.twSlate500)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: 30) {
                    // ================= 顶部控制台 =================
                    HStack(alignment: .center) {
                        HStack(spacing: 8) {
                            Circle().fill(Color.twSky500).frame(width: 6, height: 6).shadow(color: Color.twSky500.opacity(0.8), radius: 4)
                            Text("共收录 \(books.count) 卷").font(.system(size: 13, weight: .bold))
                        }
                        .foregroundColor(isDark ? .twSlate200 : .twSlate700)
                        .padding(.horizontal, 16).padding(.vertical, 8)
                        .background(isDark ? Color.twSlate800.opacity(0.5) : Color.white.opacity(0.8)).background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(isDark ? Color.white.opacity(0.1) : Color.twSlate200.opacity(0.8), lineWidth: 1))
                        .shadow(color: Color.black.opacity(isDark ? 0.2 : 0.05), radius: 8, y: 4)
                                                
                        Spacer()
                                                
                        HStack(spacing: 16) {
                            CarouselNavButton(icon: "chevron.left") { moveIndex(delta: -1) }
                            CarouselNavButton(icon: "chevron.right") { moveIndex(delta: 1) }
                        }
                    }
                    .frame(width: 1200)
                    
                    // ================= 3D 画廊 =================
                    ZStack {
                        ForEach(Array(books.enumerated()), id: \.element.id) { index, book in
                            CarouselCardItem(book: book, index: index, currentIndex: currentIndex, totalCount: books.count, isDark: isDark)
                                .onTapGesture {
                                    if index != currentIndex {
                                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { currentIndex = index }
                                    }
                                }
                        }
                        
                        if !books.isEmpty {
                            Rectangle()
                                .fill(Color.black.opacity(0.001))
                                .frame(width: 350, height: 525)
                                .offset(y: -10)
                                .zIndex(9999)
                                .onHover { isHovered in
                                    isHoveringCenter = isHovered
                                    DispatchQueue.main.async { if isHovered { NSCursor.pointingHand.push() } else { NSCursor.pop() } }
                                }
                                .gesture(
                                    DragGesture().onEnded { value in
                                        let threshold: CGFloat = 30
                                        if value.translation.width < -threshold { moveIndex(delta: -1) }
                                        else if value.translation.width > threshold { moveIndex(delta: 1) }
                                    }
                                )
                        }
                    }
                    .frame(maxWidth: .infinity)
                    // ✨ 空间撑开：从 550 提升到 640，完美容纳 525 高度的巨型卡片及下方文字！
                    .frame(height: 640)
                    
                    // ================= 底部全息光影展台 (替代原本单调的 Ellipse) =================
                    ZStack {
                        // 1. 宽广的基础环境投影 (营造空间感)
                        Ellipse()
                            .fill(RadialGradient(colors: [isDark ? Color.white.opacity(0.08) : Color.black.opacity(0.05), .clear], center: .center, startRadius: 50, endRadius: 350))
                            .frame(width: 1200, height: 40)
                        
                        // 2. 科技感渐变霓虹丝线 (打造玻璃地平线)
                        Rectangle()
                            .fill(LinearGradient(colors: [.clear, .twIndigo500.opacity(0.5), .twSky300.opacity(0.8), .twIndigo500.opacity(0.5), .clear], startPoint: .leading, endPoint: .trailing))
                            .frame(width: 800, height: 1)
                            .shadow(color: Color.twSky300.opacity(0.6), radius: 6, y: -2)
                        
                        // 3. 中心的高亮能量汇聚点
                        Circle()
                            .fill(Color.white)
                            .frame(width: 60, height: 1)
                            .blur(radius: 1)
                    }
                    // ✨ 间距优化：修正之前的 -60，微调让地平线完美托住上方的卡片文字
                    .offset(y: -20)
                    .allowsHitTesting(false)
                }
            }
        }
        .onAppear {
            scrollEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { event in
                if isHoveringCenter {
                    if abs(event.scrollingDeltaX) > abs(event.scrollingDeltaY) { handleScroll(event: event); return nil }
                }
                return event
            }
        }
        .onDisappear {
            if let monitor = scrollEventMonitor { NSEvent.removeMonitor(monitor) }
            if isHoveringCenter { NSCursor.pop() }
        }
    }
    
    private func handleScroll(event: NSEvent) {
        guard !isScrolling else { return }
        let threshold: CGFloat = event.hasPreciseScrollingDeltas ? 15.0 : 1.0
        let deltaX = event.scrollingDeltaX
        if deltaX < -threshold {
            isScrolling = true; moveIndex(delta: 1); DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) { isScrolling = false }
        } else if deltaX > threshold {
            isScrolling = true; moveIndex(delta: -1); DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) { isScrolling = false }
        }
    }
    
    private func moveIndex(delta: Int) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            let nextIndex = currentIndex + delta
            if nextIndex >= books.count { currentIndex = 0 }
            else if nextIndex < 0 { currentIndex = books.count - 1 }
            else { currentIndex = nextIndex }
        }
    }
}

private struct CarouselNavButton: View {
    let icon: String
    let action: () -> Void
    
    @State private var isHovered = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        let isDark = colorScheme == .dark
        
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(isDark ? .white : .twSlate700)
                .scaleEffect(isHovered ? 1.15 : 1.0)
                .frame(width: 48, height: 48)
                .liquidCircleGlass(isHovered: isHovered, isDark: isDark)
        }
        .buttonStyle(.plain)
        .pointingHand()
        .onHover { h in withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) { isHovered = h } }
    }
}

// MARK: - 3D 轮播卡片

private struct CarouselCardItem: View {
    let book: Book; let index: Int; let currentIndex: Int; let totalCount: Int
    let isDark: Bool // 接收深色模式状态
    let cardWidth: CGFloat = 350; let cardHeight: CGFloat = 525
    
    var body: some View {
        var diff = index - currentIndex
        let half = totalCount / 2
        if diff > half { diff -= totalCount }
        if diff < -half { diff += totalCount }
        let absDiff = abs(diff)
        let isCenter = diff == 0
        let translateX = CGFloat(diff) * 120
        let rotateY = Double(diff) * -35
        let scale = isCenter ? 1.0 : max(1.0 - CGFloat(absDiff) * 0.15, 0.4)
        let cardOpacity = absDiff > 4 ? 0.0 : 1.0 - Double(absDiff) * 0.15
        
        return VStack(spacing: 24) {
            ZStack {
                LocalCoverView(coverData: book.coverData, fallbackTitle: book.title).frame(width: cardWidth, height: cardHeight)
                
                // 非中心卡片压暗，增加景深感
                if !isCenter { Color.black.opacity(min(0.6, Double(absDiff) * 0.25)) }
                
                // ✨ 强化高光反射效果，让卡片质感更像水晶
                LinearGradient(colors: [.clear, .white.opacity(0.02), .white.opacity(0.18)], startPoint: .bottomLeading, endPoint: .topTrailing)
                
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(isCenter ? Color.white.opacity(0.25) : Color.white.opacity(0.1), lineWidth: isCenter ? 1.5 : 1)
            }
            .frame(width: cardWidth, height: cardHeight)
            // 接入系统的柔和切角
            .appleClip(radius: AppleRadius.card)
            // ✨ 中心卡片散发蓝紫色神秘光晕，两侧卡片保持深邃阴影
            .shadow(color: isCenter ? Color.twIndigo500.opacity(isDark ? 0.4 : 0.2) : Color.black.opacity(0.4),
                    radius: isCenter ? 40 : 15,
                    x: 0,
                    y: isCenter ? 25 : 10)
            
            VStack(spacing: 6) {
                Text(book.title)
                    .font(.system(size: 30, weight: .semibold, design: .rounded))
                    .foregroundColor(isDark ? .white : .twSlate800)
                    .lineLimit(1)
                    // 中心标题轻微发光
                    .shadow(color: isDark ? Color.white.opacity(0.2) : .clear, radius: 4)
                
                Text(book.author.uppercased())
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .tracking(3)
                    .foregroundColor(.twIndigo500)
            }
            .frame(width: cardWidth + 100)
            .opacity(isCenter ? 1 : 0)
            .offset(y: isCenter ? 0 : 20)
            .blur(radius: isCenter ? 0 : 5)
        }
        .rotation3DEffect(.degrees(rotateY), axis: (x: 0, y: 1, z: 0), perspective: 0.8)
        .scaleEffect(scale)
        .offset(x: translateX, y: isCenter ? -10 : 0)
        .zIndex(Double(100 - absDiff))
        .opacity(cardOpacity)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentIndex)
    }
}
