import SwiftData
import SwiftUI

struct CarouselWidget: View {
    let books: [Book]
    
    // 🗑️ 删除了 namespace、selectedBook、activeCoverID 等跳转状态
    
    @State private var currentIndex: Int = 0
    @State private var isScrolling = false
    @State private var isHoveringCenter = false
    @State private var scrollEventMonitor: Any?
    
    var body: some View {
        VStack(spacing: 10) {
            // ================= 1. 顶部控制台 =================
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .center, spacing: 12) {
                        Text("所有珍藏").font(.system(size: 32, weight: .black, design: .rounded))
                        Text("\(books.count)").font(.system(size: 14, weight: .bold)).foregroundColor(.indigo).padding(.horizontal, 10).padding(.vertical, 4).background(Color.indigo.opacity(0.1)).clipShape(Capsule())
                    }
                    Text("将鼠标置于中心卡片以滑动，或点击两侧卡片翻转").font(.subheadline).foregroundColor(.secondary)
                }
                Spacer()
                HStack(spacing: 15) {
                    navButton(icon: "chevron.left") { moveIndex(delta: -1) }
                    navButton(icon: "chevron.right") { moveIndex(delta: 1) }
                }
            }
            
            // ================= 2. 3D 画廊主体 =================
            ZStack {
                // 📚 [底层视觉层]
                ForEach(Array(books.enumerated()), id: \.element.id) { index, book in
                    // 🗑️ 清理了 selectedBook 传值
                    CarouselCardItem(
                        book: book,
                        index: index,
                        currentIndex: currentIndex,
                        totalCount: books.count
                    )
                    .onTapGesture {
                        if index != currentIndex {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { currentIndex = index }
                        }
                    }
                }
                
                // 🛡️ [顶层交互层：仅保留手势和光标悬停]
                if !books.isEmpty {
                    Rectangle()
                        .fill(Color.black.opacity(0.001))
                        .frame(width: 220, height: 330)
                        .offset(y: -10)
                        .zIndex(9999)
                        // 🗑️ 删除了 onTapGesture 里的跳转逻辑
                        .onHover { isHovered in
                            isHoveringCenter = isHovered
                            DispatchQueue.main.async {
                                if isHovered { NSCursor.pointingHand.push() } else { NSCursor.pop() }
                            }
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
        .onAppear {
            #if os(macOS)
            scrollEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { event in
                if isHoveringCenter {
                    if abs(event.scrollingDeltaX) > abs(event.scrollingDeltaY) { handleScroll(event: event); return nil }
                }
                return event
            }
            #endif
        }
        .onDisappear {
            #if os(macOS)
            if let monitor = scrollEventMonitor { NSEvent.removeMonitor(monitor) }
            if isHoveringCenter { NSCursor.pop() }
            #endif
        }
    }
    
    #if os(macOS)
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
    #endif
    
    private func moveIndex(delta: Int) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            let nextIndex = currentIndex + delta
            if nextIndex >= books.count { currentIndex = 0 }
            else if nextIndex < 0 { currentIndex = books.count - 1 }
            else { currentIndex = nextIndex }
        }
    }
    
    private func navButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) { Image(systemName: icon).font(.system(size: 16, weight: .bold)).foregroundColor(.secondary).frame(width: 44, height: 44).background(Color(NSColor.controlBackgroundColor).opacity(0.8)).clipShape(Circle()).overlay(Circle().stroke(Color.primary.opacity(0.1), lineWidth: 1)).shadow(color: .black.opacity(0.05), radius: 5, y: 2) }.buttonStyle(.plain)
    }
}

#Preview("Ultra Wide Mode") {
    let mockBooks = [
        Book(title: "活着", author: "余华", status: "READING", tags: []),
        Book(title: "茶花女", author: "小仲马", status: "READING", tags: [])
    ]
    
    // 🗑️ 清理了 Preview 中不再需要的各种占位绑定
    CarouselWidget(books: mockBooks)
        .padding(.vertical, 40)
        .preferredColorScheme(.light)
        .modelContainer(PreviewData.shared)
        .frame(width: 1400)
}
