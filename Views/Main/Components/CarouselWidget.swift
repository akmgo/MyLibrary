import SwiftUI
import SwiftData

struct CarouselWidget: View {
    let books: [Book]
    var namespace: Namespace.ID
    @Binding var selectedBook: Book?
    
    @State private var currentIndex: Int = 0
    @State private var isScrolling = false
    
    // ✨ 新增：精准的中心判定锁
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
            .padding(.horizontal, 40)
            
            // ================= 2. 3D 画廊主体 =================
            ZStack {
                // 📚 [底层视觉层] 负责渲染所有卡片
                ForEach(Array(books.enumerated()), id: \.element.id) { index, book in
                    CarouselCardItem(
                        book: book,
                        index: index,
                        currentIndex: currentIndex,
                        totalCount: books.count,
                        namespace: namespace,
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
                    // 悬浮一块与中心卡片大小完全一致的隐形玻璃
                    Rectangle()
                        .fill(Color.black.opacity(0.001)) // 纯透明，但能被 SwiftUI 完美识别
                        .frame(width: 220, height: 330)   // 精准匹配卡片封面尺寸
                        .offset(y: -10)                   // 匹配中心卡片上浮偏移
                        .zIndex(9999)                     // 保证它永远在最上面，不会被任何 3D 卡片遮挡
                        
                        // ✨ 1. 精准控制鼠标变手型
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
                        
                        // ✨ 2. 点击中心卡片，展开书籍详情
                        .onTapGesture {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                selectedBook = books[currentIndex]
                            }
                        }
                        
                        // ✨ 3. 拦截鼠标拖拽手势
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
        }
        // ================= 3. 触控板全局安全拦截 =================
        .onAppear {
            #if os(macOS)
            // 在视图加载时，挂载一个全局鼠标事件监听器
            scrollEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { event in
                // 🌟 核心逻辑：只有当鼠标悬停在中心卡片时，才拦截横向滑动！
                if isHoveringCenter {
                    if abs(event.scrollingDeltaX) > abs(event.scrollingDeltaY) {
                        handleScroll(event: event)
                        return nil // 吸收事件，不传给底层的滚动条
                    }
                }
                return event // 如果鼠标在边缘，直接放行，不做任何处理
            }
            #endif
        }
        .onDisappear {
            // 视图销毁时务必清理监听器和指针，防止内存泄漏和鼠标卡死
            #if os(macOS)
            if let monitor = scrollEventMonitor {
                NSEvent.removeMonitor(monitor)
            }
            if isHoveringCenter { NSCursor.pop() }
            #endif
        }
    }
    
    // ===================================
        // ✨ 精密的触控板防抖与翻页引擎
        // ===================================
        #if os(macOS)
        private func handleScroll(event: NSEvent) {
            guard !isScrolling else { return } // 防抖锁
            
            // ✨ 优化 1：提高触控板的触发门槛 (从 3.0 提高到 15.0)
            // 这样可以过滤掉手指的轻微颤抖，必须是有意图的滑动才会触发
            let threshold: CGFloat = event.hasPreciseScrollingDeltas ? 15.0 : 1.0
            let deltaX = event.scrollingDeltaX
            
            // ✨ 优化 2：方向反转与延长冷却时间
            if deltaX < -threshold {
                isScrolling = true
                // 手指往左划 -> 看下一本 (右边的书)
                moveIndex(delta: 1)
                // 冷却时间延长到 0.55 秒，彻底隔绝触控板的“惯性余震”
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) { isScrolling = false }
                
            } else if deltaX > threshold {
                isScrolling = true
                // 手指往右划 -> 看上一本 (左边的书)
                moveIndex(delta: -1)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) { isScrolling = false }
            }
        }
        #endif
    
    // 无限循环逻辑
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
    
    // 导航按钮
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

// ===============================================
// 预览环境
// ===============================================
#Preview("Ultra Wide Mode") {
    @Previewable @State var selected: Book? = nil
    @Previewable @Namespace var ns
    
    let mockBooks = [
        Book(title: "活着", author: "余华", status: "READING", tags: []),
        Book(title: "茶花女", author: "小仲马", status: "READING", tags: []),
        Book(title: "悉达多", author: "黑塞", status: "READING", tags: []),
        Book(title: "百年孤独", author: "马尔克斯", status: "READING", tags: []),
        Book(title: "人类简史", author: "赫拉利", status: "READING", tags: []),
        Book(title: "三体", author: "刘慈欣", status: "READING", tags: []),
        Book(title: "理想国", author: "柏拉图", status: "READING", tags: []),
        Book(title: "局外人", author: "加缪", status: "READING", tags: []),
        Book(title: "月亮与六便士", author: "毛姆", status: "READING", tags: [])
    ]
    
    CarouselWidget(books: mockBooks, namespace: ns, selectedBook: $selected)
        .padding(.vertical, 40)
        .preferredColorScheme(.light)
        .modelContainer(PreviewData.shared)
        .frame(width: 1400)
}
