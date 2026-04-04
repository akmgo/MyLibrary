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
    @State private var activeAmbientColor: Color = .twIndigo500 // 环境光
    
    var body: some View {
        let isDark = colorScheme == .dark
        
        Group {
            if books.isEmpty {
                Text("暂无书籍，去主页录入第一本吧")
                    .foregroundColor(.twSlate500)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // 🚀 新增：用 ZStack 包裹整个 3D 展览区域，铺设全屏环境光
                ZStack {
                    // 🚀 随 C位 卡片变色的全屏巨大光晕
                    RadialGradient(
                        colors: [
                            activeAmbientColor.opacity(isDark ? 0.6 : 0.4),
                            activeAmbientColor.opacity(isDark ? 0.2 : 0.1),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 1000
                    )
                    .blendMode(isDark ? .screen : .normal)
                    .ignoresSafeArea()
                    // 确保 C位 卡片切换时，背景光晕丝滑过渡
                    .animation(.easeInOut(duration: 0.8), value: activeAmbientColor)
                                    
                    // 这是你原本的整个控制台 + 轮播图 + 地平线展台
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
                                if isCardVisible(index: index, currentIndex: currentIndex, totalCount: books.count) {
                                    CarouselCardItem(
                                        book: book,
                                        index: index,
                                        currentIndex: currentIndex,
                                        totalCount: books.count,
                                        isDark: isDark,
                                        ambientColor: activeAmbientColor
                                    )
                                    .onTapGesture {
                                        if index != currentIndex {
                                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { currentIndex = index }
                                        }
                                    }
                                }
                            }
                                            
                            if !books.isEmpty {
                                Rectangle()
                                    .fill(Color.white.opacity(0.001))
                                    .contentShape(Rectangle())
                                    .frame(width: 350, height: 525)
                                    .offset(y: -10)
                                    .zIndex(10000)
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
                        .frame(height: 640)
                                        
                        // ================= 底部全息光影展台 =================
                        ZStack {
                            Ellipse()
                                .fill(RadialGradient(colors: [activeAmbientColor.opacity(isDark ? 0.2 : 0.1), .clear], center: .center, startRadius: 50, endRadius: 350))
                                .frame(width: 1200, height: 40)
                                            
                            Rectangle()
                                .fill(LinearGradient(colors: [.clear, activeAmbientColor.opacity(0.4), activeAmbientColor, activeAmbientColor.opacity(0.4), .clear], startPoint: .leading, endPoint: .trailing))
                                .frame(width: 800, height: 2)
                                .shadow(color: activeAmbientColor.opacity(0.8), radius: 8, y: -2)
                                            
                            Circle()
                                .fill(Color.white)
                                .frame(width: 60, height: 2)
                                .blur(radius: 1)
                        }
                        .offset(y: -20)
                        .allowsHitTesting(false)
                    }
                } // 结束 ZStack
            }
        }
        .onChange(of: currentIndex) { _, newIndex in
            if books.indices.contains(newIndex) {
                let currentBook = books[newIndex]
                Task {
                    let color = await CoverColorExtractor.shared.getDominantColor(from: currentBook.coverData, id: currentBook.id)
                    withAnimation(.easeInOut(duration: 0.8)) { self.activeAmbientColor = color }
                }
            }
        }
        .onAppear {
            if let firstBook = books.first {
                Task { activeAmbientColor = await CoverColorExtractor.shared.getDominantColor(from: firstBook.coverData, id: firstBook.id) }
            }
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
    
    /// 🚀 核心控制逻辑：只有距离中心位置不超过 5 张的卡片，才被允许挂载到内存中渲染
    private func isCardVisible(index: Int, currentIndex: Int, totalCount: Int) -> Bool {
        if totalCount <= 11 { return true }
        var diff = index - currentIndex
        let half = totalCount / 2
        if diff > half { diff -= totalCount }
        if diff < -half { diff += totalCount }
        return abs(diff) <= 5
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

private struct CarouselCardItem: View {
    let book: Book; let index: Int; let currentIndex: Int; let totalCount: Int
    let isDark: Bool
    let ambientColor: Color
    
    let cardWidth: CGFloat = 350; let cardHeight: CGFloat = 525
    
    var body: some View {
        // 安全保护，防止在临界状态越界
        let safeCurrentIndex = min(max(currentIndex, 0), totalCount - 1)
        var diff = index - safeCurrentIndex
        let half = totalCount / 2
        if diff > half { diff -= totalCount }
        if diff < -half { diff += totalCount }
        let absDiff = abs(diff)
        let isCenter = diff == 0
        let translateX = CGFloat(diff) * 120
        let rotateY = Double(diff) * -35
        let scale = isCenter ? 1.0 : max(1.0 - CGFloat(absDiff) * 0.15, 0.4)
        
        // 🚀 透明度过滤配合剔除算法，保证卡片出现/消失时极其平滑
        let cardOpacity = absDiff > 4 ? 0.0 : 1.0 - Double(absDiff) * 0.15
        
        return VStack(spacing: 24) {
            ZStack {
                LocalCoverView(coverData: book.coverData, fallbackTitle: book.title).frame(width: cardWidth, height: cardHeight)
                
                if !isCenter { Color.black.opacity(min(0.6, Double(absDiff) * 0.25)) }
                
                LinearGradient(colors: [.clear, .white.opacity(0.02), .white.opacity(0.18)], startPoint: .bottomLeading, endPoint: .topTrailing)
                
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(isCenter ? Color.white.opacity(0.25) : Color.white.opacity(0.1), lineWidth: isCenter ? 1.5 : 1)
            }
            .frame(width: cardWidth, height: cardHeight)
            .appleClip(radius: AppleRadius.card)
            .shadow(color: isCenter ? ambientColor.opacity(isDark ? 0.5 : 0.3) : Color.black.opacity(0.4),
                    radius: isCenter ? 40 : 15, x: 0, y: isCenter ? 25 : 10)
            
            VStack(spacing: 6) {
                Text(book.title)
                    .font(.system(size: 30, weight: .semibold, design: .rounded))
                    .foregroundColor(isCenter ? ambientColor : (isDark ? .white : .twSlate800))
                    .lineLimit(1)
                    .shadow(color: isDark ? Color.white.opacity(0.2) : .clear, radius: 4)
                
                Text(book.author.uppercased())
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .tracking(3)
                    .foregroundColor(isCenter ? ambientColor.opacity(0.7) : .twIndigo500)
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
