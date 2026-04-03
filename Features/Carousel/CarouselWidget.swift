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
        Group {
            if books.isEmpty {
                Text("暂无书籍，去主页录入第一本吧")
                    .foregroundColor(.twSlate500)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: 30) { // ✨ 加大标题和画廊的间距
                    // ================= 顶部控制台 =================
                    HStack(alignment: .center) {
                        let isDark = colorScheme == .dark
                                                
                        // ✨ 替换：极其精致的“共收录”胶囊 (与画廊完全同款)
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
                                                
                        // 右侧的滑动按钮保持不变
                        HStack(spacing: 16) {
                            CarouselNavButton(icon: "chevron.left") { moveIndex(delta: -1) }
                            CarouselNavButton(icon: "chevron.right") { moveIndex(delta: 1) }
                        }
                    }
                    .frame(width: 1200)
                    
                    // ================= 3D 画廊 =================
                    ZStack {
                        ForEach(Array(books.enumerated()), id: \.element.id) { index, book in
                            CarouselCardItem(book: book, index: index, currentIndex: currentIndex, totalCount: books.count)
                                .onTapGesture {
                                    if index != currentIndex {
                                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { currentIndex = index }
                                    }
                                }
                        }
                        
                        if !books.isEmpty {
                            Rectangle()
                                .fill(Color.black.opacity(0.001))
                                .frame(width: 220, height: 330)
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
                    .frame(height: 550)
                    
                    Ellipse()
                        .fill(RadialGradient(colors: [Color.primary.opacity(0.08), .clear], center: .center, startRadius: 50, endRadius: 400))
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .offset(y: -60)
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
                .scaleEffect(isHovered ? 1.15 : 1.0) // 内部图标微动
                .frame(width: 48, height: 48)
                // ✨ 一键调用全局引擎！极其清爽！
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
    let cardWidth: CGFloat = 220; let cardHeight: CGFloat = 330
    
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
                if !isCenter { Color.black.opacity(min(0.6, Double(absDiff) * 0.2)) }
                LinearGradient(colors: [.clear, .white.opacity(0.05), .white.opacity(0.2)], startPoint: .bottomLeading, endPoint: .topTrailing)
                RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.white.opacity(0.15), lineWidth: 1)
            }
            .frame(width: cardWidth, height: cardHeight).clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: isCenter ? Color.indigo.opacity(0.5) : Color.black.opacity(0.3), radius: isCenter ? 30 : 15, x: 0, y: isCenter ? 20 : 10)
            
            VStack(spacing: 6) {
                Text(book.title).font(.system(size: 24, weight: .black, design: .rounded)).foregroundColor(.primary).lineLimit(1)
                Text(book.author.uppercased()).font(.system(size: 14, weight: .bold, design: .rounded)).tracking(2).foregroundColor(.indigo)
            }.frame(width: cardWidth + 80).opacity(isCenter ? 1 : 0).offset(y: isCenter ? 0 : 20).blur(radius: isCenter ? 0 : 5)
        }
        .rotation3DEffect(.degrees(rotateY), axis: (x: 0, y: 1, z: 0), perspective: 0.8).scaleEffect(scale).offset(x: translateX, y: isCenter ? -10 : 0)
        .zIndex(Double(100 - absDiff)).opacity(cardOpacity).animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentIndex)
    }
}
