import SwiftData
import SwiftUI

struct BookDossierView: View {
    @Bindable var book: Book
    var namespace: Namespace.ID
    var activeCoverID: String
    var showContent: Bool
    
    // ✨ 1. 引入数据库上下文，用于查询想读数量
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    @State private var isHovered = false
    @State private var hoverRating: Int = 0
    @Namespace private var animationNamespace
    
    @State private var showStartDatePicker = false
    @State private var showEndDatePicker = false
    
    @State private var showMaxWantToReadAlert = false
    
    let statusOptions = [("UNREAD", "待读"), ("READING", "在读"), ("FINISHED", "已读完")]
    let ratingTexts = ["", "⭐ 一星毒草", "⭐⭐ 二星平庸", "⭐⭐⭐ 三星粮草", "⭐⭐⭐⭐ 四星推荐", "🔥 改变人生"]
    let predefinedTags = ["哲学", "历史", "人文", "经典", "社会", "政治", "经济", "法律", "心理", "思考", "成长", "教育", "管理", "商业", "投资", "技术", "文学", "传记", "艺术", "宗教", "科普", "编程"]
    
    var body: some View {
        let isDark = colorScheme == .dark
        
        ZStack {
            // ================= 独立光晕层 =================
            GeometryReader { _ in
                Circle().fill(Color.twSky500.opacity(isDark ? 0.1 : 0.2)).frame(width: 400, height: 400).blur(radius: 100).position(x: 0, y: 0)
            }
            .allowsHitTesting(false).opacity(showContent ? 1 : 0)
            
            VStack(spacing: 40) {
                HStack(alignment: .top, spacing: 60) {
                    // 👉 左侧：封面降落区
                    ZStack {
                        Circle().fill(Color.twIndigo500.opacity(0.2)).frame(width: 220, height: 220).blur(radius: 40).offset(y: 20).opacity(showContent ? 1 : 0)
                                            
                        LocalCoverView(coverData: book.coverData, fallbackTitle: book.title)
                            // ✨ 核心修复：1. 先圆角 2.再匹配 3.最后 Frame，和起飞卡片一模一样！
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .matchedGeometryEffect(id: activeCoverID, in: namespace)
                            .frame(width: 260, height: 390)
                            .overlay(
                                GeometryReader { geo in
                                    Rectangle().fill(LinearGradient(colors: [.clear, .white.opacity(0.3), .clear], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 100).offset(x: isHovered ? geo.size.width : -100)
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous)).opacity(showContent ? 1 : 0)
                            )
                            .zIndex(999)
                            .shadow(color: .black.opacity(showContent ? (isHovered ? 0.6 : 0.3) : 0), radius: isHovered ? 40 : 20, y: isHovered ? 25 : 12)
                    }
                    .frame(width: 260, height: 390)
                    .tiltCardEffect() // 恢复你的 3D 倾斜效果
                    .zIndex(999)
                    
                    // 👉 右侧：表单控制交互区
                    VStack(alignment: .leading, spacing: 0) {
                        // ✨ 核心替换：书名、作者与想读徽章的完美布局
                        HStack(alignment: .center) { // 改为 center，让按钮和文字垂直居中对齐
                            Text(book.title)
                                .font(.system(size: 42, weight: .black, design: .rounded))
                                .foregroundColor(isDark ? .white : .twSlate800)
                                .lineLimit(2)
                                
                            Spacer(minLength: 20)
                                
                            // 将作者和按钮打包在右侧
                            HStack(spacing: 20) {
                                Text(book.author)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(isDark ? .twSlate400 : .twSlate500)
                                    .textCase(.uppercase)
                                    .tracking(2)
                                    
                                // ✨ 专属想读液态按钮
                                WantToReadToggle(
                                    isWantToRead: book.isWantToRead,
                                    isDark: isDark,
                                    onToggle: {
                                        handleWantToReadToggle()
                                    }
                                )
                            }
                        }
                        // ✨ 拦截弹窗：当超过 3 本时触发
                        .alert("席位已满", isPresented: $showMaxWantToReadAlert) {
                            Button("知道啦", role: .cancel) {}
                        } message: {
                            Text("你的主页“想读焦点”最多只能同时放置 3 本书。请先取消其他的想读状态，把位置腾出来吧！")
                        }
                        
                        Spacer(minLength: 16)
                        Divider().background(isDark ? Color.white.opacity(0.1) : Color.twSlate200)
                        Spacer(minLength: 20)
                        
                        // ✨ 组件 1：状态与智能联动
                        VStack(alignment: .leading, spacing: 12) {
                            Label("当前状态", systemImage: "book.fill").font(.system(size: 14, weight: .bold)).foregroundColor(isDark ? .twSlate400 : .twSlate600)
                            
                            HStack(spacing: 0) {
                                ForEach(statusOptions, id: \.0) { opt in
                                    let isSelected = book.status == opt.0
                                    Button(action: {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                            book.status = opt.0
                                            if opt.0 == "READING", book.startTime == nil {
                                                book.startTime = Date()
                                            } else if opt.0 == "FINISHED" {
                                                if book.startTime == nil { book.startTime = Date() }
                                                if book.endTime == nil { book.endTime = Date() }
                                            }
                                        }
                                    }) {
                                        ZStack {
                                            if isSelected {
                                                RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.twIndigo500).shadow(color: Color.twIndigo500.opacity(0.3), radius: 5, y: 2)
                                                    .matchedGeometryEffect(id: "status-bg", in: animationNamespace)
                                            }
                                            Text(opt.1).font(.system(size: 14, weight: isSelected ? .bold : .medium)).foregroundColor(isSelected ? .white : (isDark ? .twSlate400 : .twSlate500))
                                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        }.frame(height: 44)
                                    }.buttonStyle(.plain).pointingHand()
                                }
                            }
                            .padding(4).background(isDark ? Color.twSlate950.opacity(0.5) : Color.twSlate100.opacity(0.5)).clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(isDark ? Color.twSlate700.opacity(0.5) : Color.twSlate200, lineWidth: 1))
                        }
                        
                        Spacer(minLength: 20)
                        
                        // ✨ 组件 2：极其优雅的内联式玻璃态日历引擎
                        VStack(alignment: .leading, spacing: 12) {
                            Label("阅读旅程", systemImage: "calendar").font(.system(size: 14, weight: .bold)).foregroundColor(isDark ? .twSlate400 : .twSlate600)
                            
                            if book.status == "UNREAD" {
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous).fill(isDark ? Color.twSlate950.opacity(0.5) : Color.twSlate100.opacity(0.5)).frame(height: 44)
                                    Text("等待翻开第一页...").font(.system(size: 14, weight: .medium, design: .serif)).italic().foregroundColor(isDark ? .twSlate500 : .twSlate400).padding(.horizontal, 20)
                                }.overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(isDark ? Color.twSlate700.opacity(0.5) : Color.twSlate200, lineWidth: 1))
                            } else {
                                VStack(spacing: 8) {
                                    // 开始日期选择器
                                    InlineDateRow(
                                        icon: "calendar.badge.play",
                                        title: "开始阅读",
                                        date: $book.startTime,
                                        isDark: isDark
                                    )
                                    
                                    // 结束日期选择器 (仅在已读完时可用)
                                    InlineDateRow(
                                        icon: "checkmark.calendar",
                                        title: "读完日期",
                                        date: $book.endTime,
                                        isDisabled: book.status != "FINISHED",
                                        isDark: isDark
                                    )
                                }
                            }
                        }
                        
                        Spacer(minLength: 20)
                        
                        // ✨ 组件 3：评分联动
                        VStack(alignment: .leading, spacing: 12) {
                            Label("个人评价", systemImage: "star.fill").font(.system(size: 14, weight: .bold)).foregroundColor(isDark ? .twSlate400 : .twSlate600)
                            HStack {
                                HStack(spacing: 8) {
                                    ForEach(1 ... 5, id: \.self) { star in
                                        let currentRating = hoverRating > 0 ? hoverRating : book.rating
                                        let isFilled = currentRating >= star
                                        Image(systemName: "star.fill").font(.system(size: 24)).foregroundColor(isFilled ? .yellow : (isDark ? .twSlate700 : .twSlate300))
                                            .shadow(color: isFilled ? Color.yellow.opacity(0.4) : .clear, radius: 5, y: 2).scaleEffect(isFilled ? 1.1 : 1.0)
                                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isFilled)
                                            .onHover { isHovering in if isHovering { hoverRating = star } else { hoverRating = 0 } }
                                            .onTapGesture { book.rating = star }
                                            .pointingHand()
                                    }
                                }
                                Spacer()
                                let displayText = hoverRating > 0 ? ratingTexts[hoverRating] : (book.rating < ratingTexts.count ? ratingTexts[book.rating] : "")
                                Text(displayText).font(.system(size: 15, weight: .bold)).foregroundColor(.yellow).animation(.none, value: displayText)
                            }
                            .padding(.horizontal, 24).frame(height: 54).frame(maxWidth: .infinity)
                            .background(isDark ? Color.twSlate950.opacity(0.4) : Color.white.opacity(0.5)).clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(isDark ? Color.twSlate700.opacity(0.5) : Color.twSlate200, lineWidth: 1))
                        }
                    }
                    .frame(height: 390).frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(showContent ? 1 : 0).offset(x: showContent ? 0 : 40).zIndex(0)
                }
                
                // ✨ 底部：知识标签库联动作
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Label("知识标签库", systemImage: "tag.fill").font(.system(size: 15, weight: .bold)).foregroundColor(.twIndigo500)
                        Spacer()
                        Text("\(book.tags.count) / 3").font(.system(size: 14, weight: .bold)).foregroundColor(isDark ? .twSlate400 : .twSlate500)
                    }
                    
                    let columns = [GridItem(.adaptive(minimum: 80, maximum: 120), spacing: 12)]
                    LazyVGrid(columns: columns, alignment: .leading, spacing: 12) {
                        ForEach(predefinedTags, id: \.self) { tag in
                            let isSelected = book.tags.contains(tag)
                            let isMaxed = book.tags.count >= 3 && !isSelected
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    if isSelected { book.tags.removeAll(where: { $0 == tag }) }
                                    else if book.tags.count < 3 { book.tags.append(tag) }
                                }
                            }) {
                                Text(tag).font(.system(size: 14, weight: isSelected ? .bold : .medium))
                                    .foregroundColor(isSelected ? .white : (isMaxed ? (isDark ? .twSlate600 : .twSlate400) : (isDark ? .twSlate300 : .twSlate600)))
                                    .frame(height: 36).frame(maxWidth: .infinity)
                                    .background(isSelected ? Color.twIndigo500 : (isMaxed ? (isDark ? Color.twSlate900.opacity(0.3) : Color.twSlate100) : (isDark ? Color.twSlate800.opacity(0.8) : Color.white)))
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(isSelected ? Color.twIndigo500 : (isDark ? Color.twSlate700 : Color.twSlate200), lineWidth: 1))
                                    .shadow(color: isSelected ? Color.twIndigo500.opacity(0.3) : .clear, radius: 8, y: 4).scaleEffect(isSelected ? 1.05 : 1.0)
                            }.buttonStyle(.plain).disabled(isMaxed).pointingHand()
                        }
                    }
                }
                .padding(.top, 10).opacity(showContent ? 1 : 0).offset(y: showContent ? 0 : 20)
            }
            .padding(40)
        }
        .background(Color.clear.outerGlassBlockStyle().opacity(showContent ? 1 : 0))
        .onHover { h in withAnimation(.spring()) { isHovered = h } }
    }
    
    // MARK: - ✨ 核心数据库逻辑：想读状态的切换与拦截

    private func handleWantToReadToggle() {
        if book.isWantToRead {
            // 如果已经是想读，直接取消，无需检查数量
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                book.isWantToRead = false
            }
        } else {
            // 如果想设为想读，必须向数据库发起严格查询
            do {
                // 构建查询：找到所有 isWantToRead 为 true 的书
                let descriptor = FetchDescriptor<Book>(predicate: #Predicate<Book> { $0.isWantToRead == true })
                let currentCount = try modelContext.fetchCount(descriptor)
                    
                if currentCount >= 3 {
                    // 超出限制，触发震动反馈(可选)并弹出警告
                    NSSound.beep() // Mac 上极其轻微的错误提示音
                    showMaxWantToReadAlert = true
                } else {
                    // 名额充足，丝滑点亮
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        book.isWantToRead = true
                    }
                }
            } catch {
                print("查询想读数量失败: \(error)")
            }
        }
    }
} // 这是 BookDossierView 的结束括号

// MARK: - ✨ 专属私有组件：内联手风琴玻璃态日历

private struct InlineDateRow: View {
    let icon: String
    let title: String
    @Binding var date: Date?
    var isDisabled: Bool = false
    let isDark: Bool
    
    @State private var isExpanded = false
    @State private var isHovered = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 触控条
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    isExpanded.toggle()
                    // 如果没有日期且展开了，自动赋个当前时间
                    if isExpanded, date == nil { date = Date() }
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: icon).foregroundColor(isExpanded ? .twSky400 : (isDark ? .twSlate400 : .twSlate500))
                    Text(title).font(.system(size: 14, weight: .medium)).foregroundColor(isDark ? .twSlate300 : .twSlate600)
                    
                    Spacer()
                    
                    // 当前日期显示
                    if let validDate = date {
                        Text(validDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(isDark ? .white : .twSlate800)
                            .padding(.horizontal, 10).padding(.vertical, 4)
                            .background(isDark ? Color.white.opacity(0.1) : Color.black.opacity(0.05))
                            .clipShape(Capsule())
                    }
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(isDark ? .twSlate500 : .twSlate400)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(.horizontal, 16)
                .frame(height: 44)
                // 悬浮时的微弱高亮
                .background(isHovered ? (isDark ? Color.white.opacity(0.05) : Color.black.opacity(0.02)) : Color.clear)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain).disabled(isDisabled).pointingHand()
            .onHover { h in withAnimation(.easeInOut(duration: 0.2)) { isHovered = h } }
            
            // 展开的日历面板
            if isExpanded {
                Divider().background(isDark ? Color.white.opacity(0.1) : Color.twSlate200).padding(.horizontal, 16)
                
                DatePicker("", selection: Binding(get: { date ?? Date() }, set: { date = $0 }), displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                    // 强制改变原生 DatePicker 的颜色适应深浅模式
                    .colorScheme(isDark ? .dark : .light)
                    .tint(.twSky500)
                    .padding(16)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(isDark ? Color.twSlate950.opacity(0.5) : Color.white.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(isExpanded ? Color.twSky500.opacity(0.5) : (isDark ? Color.twSlate700.opacity(0.5) : Color.twSlate200), lineWidth: 1))
        .opacity(isDisabled ? 0.4 : 1.0)
    }
}

// MARK: - ✨ 专属私有组件：想读液态徽章

private struct WantToReadToggle: View {
    let isWantToRead: Bool
    let isDark: Bool
    let onToggle: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: onToggle) {
            Image(systemName: isWantToRead ? "bookmark.fill" : "bookmark")
                .font(.system(size: 16, weight: .bold))
                // 点亮时赋予主页想读专区同款的 twOrange500 活力橙色
                .foregroundColor(isWantToRead ? .twOrange500 : (isDark ? .twSlate400 : .twSlate500))
                .frame(width: 44, height: 44)
                // 完美复用你的全局液态圆环设计
                .liquidCircleGlass(isHovered: isHovered, isDark: isDark)
                // 点亮状态增加额外的微光晕
                .shadow(color: isWantToRead ? Color.twOrange500.opacity(isHovered ? 0.4 : 0.15) : .clear, radius: 8, y: 2)
        }
        .buttonStyle(.plain)
        .pointingHand()
        .onHover { h in withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { isHovered = h } }
        // 增加专属的呼吸起伏感
        .scaleEffect(isWantToRead ? (isHovered ? 1.08 : 1.0) : (isHovered ? 1.05 : 1.0))
        .help(isWantToRead ? "取消想读焦点" : "加入主页想读焦点 (最多3本)") // macOS 原生的 Hover 提示
    }
}
