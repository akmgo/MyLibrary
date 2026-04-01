import SwiftData
import SwiftUI

struct CarouselWidget: View {
    let books: [Book]
    @Binding var selectedBook: Book?
    
    @State private var currentIndex: Int = 0
    @State private var isScrolling = false
    
    // 精准的中心判定锁
    @State private var isHoveringCenter = false
    @State private var scrollEventMonitor: Any?
    
    var body: some View {
        VStack(spacing: 10) {
            // ================= 1. 顶部控制台 =================
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .center, spacing: 12) {
                        Text("所有珍藏")
                            .font(.system(size: 32, weight: .black, design: .rounded))
                        
                        Text("\(books.count)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.indigo)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.indigo.opacity(0.1))
                            .clipShape(Capsule())
                    }
                    Text("将鼠标置于中心卡片以滑动，或点击两侧卡片翻转")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 15) {
                    navButton(icon: "chevron.left") { moveIndex(delta: -1) }
                    navButton(icon: "chevron.right") { moveIndex(delta: 1) }
                }
            }
            
            // ================= 2. 3D 画廊主体 =================
            ZStack {
                // 📚 [底层视觉层] 负责渲染所有卡片
                ForEach(Array(books.enumerated()), id: \.element.id) { index, book in
                    CarouselCardItem(
                        book: book,
                        index: index,
                        currentIndex: currentIndex,
                        totalCount: books.count,
                        selectedBook: selectedBook
                    )
                    .onTapGesture {
                        // 依然允许点击两侧漏出来的卡片，使其翻转到中心
                        if index != currentIndex {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                currentIndex = index
                            }
                        }
                    }
                }
                
                // 🛡️ [顶层交互层] 专属中心交互面板 (Hitbox)
                if !books.isEmpty {
                    Rectangle()
                        .fill(Color.black.opacity(0.001)) // 纯透明，但能被 SwiftUI 完美识别
                        .frame(width: 220, height: 330) // 精准匹配卡片封面尺寸
                        .offset(y: -10) // 匹配中心卡片上浮偏移
                        .zIndex(9999) // 保证它永远在最上面，不会被任何 3D 卡片遮挡
                        .onHover { isHovered in
                            isHoveringCenter = isHovered // 更新全局状态锁
                            DispatchQueue.main.async {
                                if isHovered {
                                    NSCursor.pointingHand.push()
                                } else {
                                    NSCursor.pop()
                                }
                            }
                        }
                        .onTapGesture {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                selectedBook = books[currentIndex]
                            }
                        }
                        .gesture(
                            DragGesture()
                                .onEnded { value in
                                    let threshold: CGFloat = 30
                                    if value.translation.width < -threshold {
                                        moveIndex(delta: -1)
                                    } else if value.translation.width > threshold {
                                        moveIndex(delta: 1)
                                    }
                                }
                        )
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 550)
            
            Ellipse()
                .fill(RadialGradient(colors: [Color.primary.opacity(0.08), .clear], center: .center, startRadius: 50, endRadius: 400))
                .frame(maxWidth: .infinity) // 舞台也要自适应无限宽
                .frame(height: 40)
                .offset(y: -60)
                .allowsHitTesting(false)
        }
        .onAppear {
            #if os(macOS)
            scrollEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { event in
                if isHoveringCenter {
                    if abs(event.scrollingDeltaX) > abs(event.scrollingDeltaY) {
                        handleScroll(event: event)
                        return nil
                    }
                }
                return event
            }
            #endif
        }
        .onDisappear {
            #if os(macOS)
            if let monitor = scrollEventMonitor {
                NSEvent.removeMonitor(monitor)
            }
            if isHoveringCenter { NSCursor.pop() }
            #endif
        }
    }
    
    #if os(macOS)
    private func handleScroll(event: NSEvent) {
        guard !isScrolling else { return } // 防抖锁
            
        let threshold: CGFloat = event.hasPreciseScrollingDeltas ? 15.0 : 1.0
        let deltaX = event.scrollingDeltaX
            
        if deltaX < -threshold {
            isScrolling = true
            moveIndex(delta: 1)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) { isScrolling = false }
                
        } else if deltaX > threshold {
            isScrolling = true
            moveIndex(delta: -1)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) { isScrolling = false }
        }
    }
    #endif
    
    private func moveIndex(delta: Int) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            let nextIndex = currentIndex + delta
            if nextIndex >= books.count {
                currentIndex = 0
            } else if nextIndex < 0 {
                currentIndex = books.count - 1
            } else {
                currentIndex = nextIndex
            }
        }
    }
    
    private func navButton(icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.secondary)
                .frame(width: 44, height: 44)
                .background(Color(NSColor.controlBackgroundColor).opacity(0.8))
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.primary.opacity(0.1), lineWidth: 1))
                .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        }
        .buttonStyle(.plain)
    }
}

#Preview("Ultra Wide Mode") {
    @Previewable @State var selected: Book? = nil
    
    let mockBooks = [
        Book(title: "活着", author: "余华", status: "READING", tags: []),
        Book(title: "茶花女", author: "小仲马", status: "READING", tags: [])
    ]
    
    CarouselWidget(books: mockBooks, selectedBook: $selected)
        .padding(.vertical, 40)
        .preferredColorScheme(.light)
        .modelContainer(PreviewData.shared)
        .frame(width: 1400)
}
