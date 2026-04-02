import SwiftUI

struct BookDossierView: View {
    @Bindable var book: Book
    var namespace: Namespace.ID
    var activeCoverID: String // ✨ 匹配目标 ID
    var showContent: Bool // ✨ 接收文本显隐开关
    
    @Environment(\.colorScheme) var colorScheme
    @State private var isHovered = false
    @State private var hoverRating: Int = 0
    @Namespace private var animationNamespace
    
    let statusOptions = [("UNREAD", "待读"), ("READING", "在读"), ("FINISHED", "已读完")]
    let ratingTexts = ["", "⭐ 一星毒草", "⭐⭐ 二星平庸", "⭐⭐⭐ 三星粮草", "⭐⭐⭐⭐ 四星推荐", "🔥 改变人生"]
    let predefinedTags = ["哲学", "历史", "人文", "经典", "社会", "政治", "经济", "法律", "心理", "思考", "成长", "教育", "管理", "商业", "投资", "技术", "文学", "传记", "艺术", "宗教", "科普", "编程"]
    
    var body: some View {
        let isDark = colorScheme == .dark
        
        ZStack {
            // ================= 独立光晕层 =================
            GeometryReader { _ in
                Circle()
                    .fill(Color.twSky500.opacity(isDark ? 0.1 : 0.2))
                    .frame(width: 400, height: 400)
                    .blur(radius: 100)
                    .position(x: 0, y: 0)
            }
            .allowsHitTesting(false)
            .opacity(showContent ? 1 : 0) // 背景光晕随内容消失
            
            VStack(spacing: 40) {
                HStack(alignment: .top, spacing: 60) {
                    // 👉 左侧：封面降落区（唯一不能消失的实体！）
                    ZStack {
                        Circle()
                            .fill(Color.twIndigo500.opacity(0.2))
                            .frame(width: 220, height: 220)
                            .blur(radius: 40)
                            .offset(y: 20)
                            .opacity(showContent ? 1 : 0) // 封面底部光晕也跟随消失
                        
                        // ✨ 绝对纯净的飞行着陆点！
                        LocalCoverView(coverData: book.coverData, fallbackTitle: book.title)
                            // 2. 切好圆角
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            // 4. ✨✨✨ 终极核心：引擎垫底！带着切好的 24 圆角卡片整体起飞，绝不被猫眼卡住！
                            .matchedGeometryEffect(id: activeCoverID, in: namespace)
                            .frame(width: 260, height: 390)
                            // 3. 附着高光层
                            .overlay(
                                GeometryReader { geo in
                                    Rectangle()
                                        .fill(LinearGradient(colors: [.clear, .white.opacity(0.3), .clear], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 100)
                                        .offset(x: isHovered ? geo.size.width : -100)
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                                .opacity(showContent ? 1 : 0)
                            )
                            
                            // 5. 让飞行物体在穿梭空间中保持最高层级
                            .zIndex(999)
                            // 6. 阴影留在最外层，受控于 showContent 的淡入淡出
                            .shadow(
                                color: .black.opacity(showContent ? (isHovered ? 0.6 : 0.3) : 0),
                                radius: isHovered ? 40 : 20,
                                y: isHovered ? 25 : 12
                            )
                    }
                    .frame(width: 260, height: 390)
                    .tiltCardEffect()
                    // ✨ 核心 1：确保左侧封面容器盖过右侧的文字
                    .zIndex(999)
                    
                    // 👉 右侧：表单控制交互区 (受 showContent 统一控制)
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(alignment: .lastTextBaseline) {
                            Text(book.title)
                                .font(.system(size: 42, weight: .black, design: .rounded))
                                .foregroundColor(isDark ? .white : .twSlate800)
                                .lineLimit(2)
                            Spacer()
                            Text(book.author)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(isDark ? .twSlate400 : .twSlate500)
                                .textCase(.uppercase)
                                .tracking(2)
                        }
                        
                        Spacer(minLength: 16)
                        Divider().background(isDark ? Color.white.opacity(0.1) : Color.twSlate200)
                        Spacer(minLength: 20)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Label("当前状态", systemImage: "book.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(isDark ? .twSlate400 : .twSlate600)
                            
                            HStack(spacing: 0) {
                                ForEach(statusOptions, id: \.0) { opt in
                                    let isSelected = book.status == opt.0
                                    Button(action: {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                            book.status = opt.0
                                        }
                                    }) {
                                        ZStack {
                                            if isSelected {
                                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                    .fill(Color.twIndigo500)
                                                    .shadow(color: Color.twIndigo500.opacity(0.3), radius: 5, y: 2)
                                                    .matchedGeometryEffect(id: "status-bg", in: animationNamespace)
                                            }
                                            Text(opt.1)
                                                .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                                                .foregroundColor(isSelected ? .white : (isDark ? .twSlate400 : .twSlate500))
                                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        }
                                        .frame(height: 44)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(4)
                            .background(isDark ? Color.twSlate950.opacity(0.5) : Color.twSlate100.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(isDark ? Color.twSlate700.opacity(0.5) : Color.twSlate200, lineWidth: 1)
                            )
                        }
                        
                        Spacer(minLength: 20)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Label("阅读旅程", systemImage: "calendar")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(isDark ? .twSlate400 : .twSlate600)
                            
                            if book.status == "UNREAD" {
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(isDark ? Color.twSlate950.opacity(0.5) : Color.twSlate100.opacity(0.5))
                                        .frame(height: 44)
                                    Text("Waiting for the journey to begin...")
                                        .font(.system(size: 14, weight: .medium, design: .serif))
                                        .italic()
                                        .foregroundColor(isDark ? .twSlate500 : .twSlate400)
                                        .padding(.horizontal, 20)
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(isDark ? Color.twSlate700.opacity(0.5) : Color.twSlate200, lineWidth: 1)
                                )
                            } else {
                                HStack(spacing: 16) {
                                    DateSelectorButton(
                                        icon: "calendar",
                                        title: book.startTime?.formatted(date: .numeric, time: .omitted) ?? "开始日期",
                                        action: {}
                                    )
                                    Text("至")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.twSlate400)
                                    DateSelectorButton(
                                        icon: "clock",
                                        title: book.endTime?.formatted(date: .numeric, time: .omitted) ?? "结束日期",
                                        isDisabled: book.status != "FINISHED",
                                        action: {}
                                    )
                                }
                            }
                        }
                        
                        Spacer(minLength: 20)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Label("个人评价", systemImage: "star.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(isDark ? .twSlate400 : .twSlate600)
                            
                            HStack {
                                HStack(spacing: 8) {
                                    ForEach(1 ... 5, id: \.self) { star in
                                        let currentRating = hoverRating > 0 ? hoverRating : book.rating
                                        let isFilled = currentRating >= star
                                        Image(systemName: "star.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(isFilled ? .yellow : (isDark ? .twSlate700 : .twSlate300))
                                            .shadow(color: isFilled ? Color.yellow.opacity(0.4) : .clear, radius: 5, y: 2)
                                            .scaleEffect(isFilled ? 1.1 : 1.0)
                                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isFilled)
                                            .onHover { isHovering in
                                                if isHovering { hoverRating = star } else { hoverRating = 0 }
                                            }
                                            .onTapGesture { book.rating = star }
                                    }
                                }
                                Spacer()
                                let displayText = hoverRating > 0 ? ratingTexts[hoverRating] : ratingTexts[book.rating]
                                Text(displayText)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.yellow)
                                    .animation(.none, value: displayText)
                            }
                            .padding(.horizontal, 24)
                            .frame(height: 54)
                            .frame(maxWidth: .infinity)
                            .background(isDark ? Color.twSlate950.opacity(0.4) : Color.white.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(isDark ? Color.twSlate700.opacity(0.5) : Color.twSlate200, lineWidth: 1)
                            )
                        }
                    }
                    .frame(height: 390)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    // ✨ 文本整体淡入淡出，不阻碍封面起降
                    .opacity(showContent ? 1 : 0)
                    .offset(x: showContent ? 0 : 40)
                    .zIndex(0) // 确保文字在底层
                }
                
                // ================= 底部标签区 =================
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Label("知识标签库", systemImage: "tag.fill")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.twIndigo500)
                        Spacer()
                        Text("\(book.tags.count) / 3")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(isDark ? .twSlate400 : .twSlate500)
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
                                Text(tag)
                                    .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                                    .foregroundColor(isSelected ? .white : (isMaxed ? (isDark ? .twSlate600 : .twSlate400) : (isDark ? .twSlate300 : .twSlate600)))
                                    .frame(height: 36)
                                    .frame(maxWidth: .infinity)
                                    .background(isSelected ? Color.twIndigo500 : (isMaxed ? (isDark ? Color.twSlate900.opacity(0.3) : Color.twSlate100) : (isDark ? Color.twSlate800.opacity(0.8) : Color.white)))
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .stroke(isSelected ? Color.twIndigo500 : (isDark ? Color.twSlate700 : Color.twSlate200), lineWidth: 1)
                                    )
                                    .shadow(color: isSelected ? Color.twIndigo500.opacity(0.3) : .clear, radius: 8, y: 4)
                                    .scaleEffect(isSelected ? 1.05 : 1.0)
                            }
                            .buttonStyle(.plain)
                            .disabled(isMaxed)
                        }
                    }
                }
                .padding(.top, 10)
                // ✨ 底部组件同样由 showContent 控制
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
            }
            .padding(40)
        }
        // ✨ 将毛玻璃提到最底层背景中，并与文本内容一同淡出
        .background(
            Color.clear
                .outerGlassBlockStyle()
                .opacity(showContent ? 1 : 0)
        )
        .onHover { h in withAnimation(.spring()) { isHovered = h } }
    }
}

/// 底部复用的 DateSelectorButton
struct DateSelectorButton: View {
    let icon: String
    let title: String
    var isDisabled: Bool = false
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        let isDark = colorScheme == .dark
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(isDark ? .twSlate400 : .twSlate400)
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isDark ? .white : .twSlate800)
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(height: 44)
            .frame(maxWidth: .infinity)
            .background(isDark ? Color.twSlate950.opacity(0.5) : Color.white.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isDark ? Color.twSlate700.opacity(0.5) : Color.twSlate200, lineWidth: 1)
            )
            .opacity(isDisabled ? 0.5 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}
