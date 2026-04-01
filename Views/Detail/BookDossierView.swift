// Views/Detail/BookDossierView.swift
import SwiftUI

struct BookDossierView: View {
    @Bindable var book: Book
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
            GeometryReader { geo in
                Circle().fill(Color.twSky500.opacity(isDark ? 0.1 : 0.2))
                    .frame(width: 400, height: 400).blur(radius: 100)
                    .position(x: 0, y: 0)
            }.allowsHitTesting(false)
            
            VStack(spacing: 40) {
                // ================= 1. 顶层左右布局 =================
                // ✨ 优化 2：基础间距设为 40，右侧自适应无限拉宽
                HStack(alignment: .top, spacing: 60) {
                    
                    // 👉 左侧：3D 动态跟随封面
                    ZStack {
                        Circle().fill(Color.twIndigo500.opacity(0.2)).frame(width: 220, height: 220).blur(radius: 40).offset(y: 20)
                        
                        LocalCoverView(coverData: book.coverData, fallbackTitle: book.title)
                            // ✨ 优化 3：封面放大至 260x390
                            .frame(width: 260, height: 390)
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .overlay(
                                GeometryReader { geo in
                                    Rectangle().fill(LinearGradient(colors: [.clear, .white.opacity(0.3), .clear], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 100).offset(x: isHovered ? geo.size.width : -100)
                                }.clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            )
                            // ✨ 优化 4：阴影加浓、扩大，悬浮感拔群
                            .shadow(color: .black.opacity(isHovered ? 0.6 : 0.3), radius: isHovered ? 40 : 20, y: isHovered ? 25 : 12)
                    }
                    .frame(width: 260, height: 390)
                    .tiltCardEffect()
                    
                    // 👉 右侧：表单控制交互区
                    // ✨ 优化 5：利用 spacing: 0 配合内部 Spacer 进行均匀分布，彻底消灭“巨型间距”
                    VStack(alignment: .leading, spacing: 0) {
                        
                        // 1.1 书名与作者
                        HStack(alignment: .lastTextBaseline) {
                            Text(book.title).font(.system(size: 42, weight: .black, design: .rounded)).foregroundColor(isDark ? .white : .twSlate800).lineLimit(2)
                            Spacer()
                            Text(book.author).font(.system(size: 18, weight: .bold)).foregroundColor(isDark ? .twSlate400 : .twSlate500).textCase(.uppercase).tracking(2)
                        }
                        
                        Spacer(minLength: 16)
                        Divider().background(isDark ? Color.white.opacity(0.1) : Color.twSlate200)
                        Spacer(minLength: 20)
                        
                        // 1.2 当前状态控制
                        VStack(alignment: .leading, spacing: 12) {
                            Label("当前状态", systemImage: "book.open.fill").font(.system(size: 14, weight: .bold)).foregroundColor(isDark ? .twSlate400 : .twSlate600)
                            
                            HStack(spacing: 0) {
                                ForEach(statusOptions, id: \.0) { opt in
                                    let isSelected = book.status == opt.0
                                    Button(action: { withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { book.status = opt.0 } }) {
                                        ZStack {
                                            if isSelected { RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.twIndigo500).shadow(color: Color.twIndigo500.opacity(0.3), radius: 5, y: 2).matchedGeometryEffect(id: "status-bg", in: animationNamespace) }
                                            Text(opt.1).font(.system(size: 14, weight: isSelected ? .bold : .medium)).foregroundColor(isSelected ? .white : (isDark ? .twSlate400 : .twSlate500)).frame(maxWidth: .infinity, maxHeight: .infinity)
                                        }.frame(height: 44)
                                    }.buttonStyle(.plain)
                                }
                            }
                            .padding(4).background(isDark ? Color.twSlate950.opacity(0.5) : Color.twSlate100.opacity(0.5)).clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous)).overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(isDark ? Color.twSlate700.opacity(0.5) : Color.twSlate200, lineWidth: 1))
                        }
                        
                        Spacer(minLength: 20)
                        
                        // 1.3 时间线记录
                        VStack(alignment: .leading, spacing: 12) {
                            Label("阅读旅程", systemImage: "calendar").font(.system(size: 14, weight: .bold)).foregroundColor(isDark ? .twSlate400 : .twSlate600)
                            
                            if book.status == "UNREAD" {
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous).fill(isDark ? Color.twSlate950.opacity(0.5) : Color.twSlate100.opacity(0.5)).frame(height: 44)
                                    Text("Waiting for the journey to begin...").font(.system(size: 14, weight: .medium, design: .serif)).italic().foregroundColor(isDark ? .twSlate500 : .twSlate400).padding(.horizontal, 20)
                                }.overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(isDark ? Color.twSlate700.opacity(0.5) : Color.twSlate200, lineWidth: 1))
                            } else {
                                HStack(spacing: 16) {
                                    DateSelectorButton(icon: "calendar", title: book.startTime?.formatted(date: .numeric, time: .omitted) ?? "开始日期", action: { })
                                    Text("至").font(.system(size: 14, weight: .bold)).foregroundColor(.twSlate400)
                                    DateSelectorButton(icon: "clock", title: book.endTime?.formatted(date: .numeric, time: .omitted) ?? "结束日期", isDisabled: book.status != "FINISHED", action: { })
                                }
                            }
                        }
                        
                        Spacer(minLength: 20)
                        
                        // 1.4 个人评价
                        VStack(alignment: .leading, spacing: 12) {
                            Label("个人评价", systemImage: "star.fill").font(.system(size: 14, weight: .bold)).foregroundColor(isDark ? .twSlate400 : .twSlate600)
                            
                            // ✨ 优化 6：将文字放进内部，并拉满宽度与其他组件对齐
                            HStack {
                                HStack(spacing: 8) {
                                    ForEach(1...5, id: \.self) { star in
                                        let currentRating = hoverRating > 0 ? hoverRating : book.rating
                                        let isFilled = currentRating >= star
                                        Image(systemName: "star.fill").font(.system(size: 24)).foregroundColor(isFilled ? .yellow : (isDark ? .twSlate700 : .twSlate300)).shadow(color: isFilled ? Color.yellow.opacity(0.4) : .clear, radius: 5, y: 2).scaleEffect(isFilled ? 1.1 : 1.0).animation(.spring(response: 0.3, dampingFraction: 0.6), value: isFilled)
                                            .onHover { isHovering in if isHovering { hoverRating = star } else { hoverRating = 0 } }.onTapGesture { book.rating = star }
                                    }
                                }
                                
                                Spacer()
                                
                                let displayText = hoverRating > 0 ? ratingTexts[hoverRating] : ratingTexts[book.rating]
                                Text(displayText).font(.system(size: 15, weight: .bold)).foregroundColor(.yellow).animation(.none, value: displayText)
                            }
                            .padding(.horizontal, 24)
                            .frame(height: 54)
                            .frame(maxWidth: .infinity) // 强制与上方组件等宽
                            .background(isDark ? Color.twSlate950.opacity(0.4) : Color.white.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(isDark ? Color.twSlate700.opacity(0.5) : Color.twSlate200, lineWidth: 1))
                        }
                    }
                    // ✨ 优化 7：强行锁死右侧高度等于封面高度 (390)，配合内部的 Spacer()，实现完美的顶底对齐！
                    .frame(height: 390)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // ================= 2. 底层知识图谱标签区 (保持不变) =================
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
                                Text(tag).font(.system(size: 14, weight: isSelected ? .bold : .medium)).foregroundColor(isSelected ? .white : (isMaxed ? (isDark ? .twSlate600 : .twSlate400) : (isDark ? .twSlate300 : .twSlate600))).frame(height: 36).frame(maxWidth: .infinity)
                                    .background(isSelected ? Color.twIndigo500 : (isMaxed ? (isDark ? Color.twSlate900.opacity(0.3) : Color.twSlate100) : (isDark ? Color.twSlate800.opacity(0.8) : Color.white)))
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(isSelected ? Color.twIndigo500 : (isDark ? Color.twSlate700 : Color.twSlate200), lineWidth: 1))
                                    .shadow(color: isSelected ? Color.twIndigo500.opacity(0.3) : .clear, radius: 8, y: 4)
                                    .scaleEffect(isSelected ? 1.05 : 1.0)
                            }.buttonStyle(.plain).disabled(isMaxed)
                        }
                    }
                }
                .padding(.top, 10)
            }
            .padding(40)
        }
        .outerGlassBlockStyle()
        .onHover { h in withAnimation(.spring()) { isHovered = h } }
    }
}

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
                Image(systemName: icon).foregroundColor(isDark ? .twSlate400 : .twSlate400)
                Text(title).font(.system(size: 14, weight: .medium)).foregroundColor(isDark ? .white : .twSlate800)
                Spacer()
            }
            .padding(.horizontal, 16).frame(height: 44).frame(maxWidth: .infinity)
            .background(isDark ? Color.twSlate950.opacity(0.5) : Color.white.opacity(0.5)).clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous)).overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(isDark ? Color.twSlate700.opacity(0.5) : Color.twSlate200, lineWidth: 1)).opacity(isDisabled ? 0.5 : 1.0)
        }.buttonStyle(.plain).disabled(isDisabled)
    }
}
