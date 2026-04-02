// Views/Detail/BookExcerptsView.swift
import SwiftData
import SwiftUI

struct BookExcerptsView: View {
    let book: Book
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showAddExcerpt = false
    
    /// ✨ 帮编译器分步处理，彻底解决类型推断报错
    private var sortedExcerpts: [Excerpt] {
        // 第一步：先拿到摘录数组，如果是 nil 就给个空数组
        let list = book.excerpts ?? []
            
        // 第二步：明确告诉编译器使用 `by:` 闭包，并显式声明 a 和 b 的类型
        return list.sorted(by: { (a: Excerpt, b: Excerpt) in
            a.createdAt > b.createdAt
        })
    }
    
    var body: some View {
        let isDark = colorScheme == .dark
        // 现在摘录模块直接渲染在页面的全局背景上
        VStack(alignment: .leading, spacing: 30) {
            // ================= 1. 顶部标题栏 =================
            VStack(spacing: 16) {
                HStack(alignment: .center) {
                    Text("摘录与笔记")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(isDark ? .white : .twSlate800)
                    
                    Spacer()
                    
                    // 添加摘录按钮 (替换为薄荷绿弹跳组件)
                    DetailAddExcerptButton {
                        showAddExcerpt = true
                    }
                }
                
                // 标题底部的分割线 (对应 border-b border-slate-200)
                Divider().background(isDark ? Color.twSlate800 : Color.twSlate200)
            }
            
            // ================= 2. 书摘流列表 =================
            if sortedExcerpts.isEmpty {
                // 空状态：虚线框提示区
                VStack(spacing: 12) {
                    Text("这本书还没有留下任何思考的痕迹")
                        .font(.system(size: 18))
                        .foregroundColor(isDark ? .twSlate400 : .twSlate500)
                    Text("点击右上角按钮，记录下你的第一条摘录")
                        .font(.system(size: 14))
                        .foregroundColor(isDark ? .twSlate600 : .twSlate400)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 240)
                .background(isDark ? Color.twSlate900.opacity(0.3) : Color.white.opacity(0.4))
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(isDark ? Color.twSlate800 : Color.twSlate300, style: StrokeStyle(lineWidth: 1, dash: [6, 6])))
            } else {
                // 瀑布流双列布局 (对应网页端的 columns-1 md:columns-2)
                let columns = [GridItem(.adaptive(minimum: 350), spacing: 24)]
                LazyVGrid(columns: columns, spacing: 24) {
                    ForEach(sortedExcerpts, id: \.id) { excerpt in
                        ExcerptCardView(content: excerpt.content, createdAt: formatDate(excerpt.createdAt))
                    }
                }
            }
        }
        .padding(.top, 20)
        .sheet(isPresented: $showAddExcerpt) {
            AddExcerptSheet(book: book)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: date)
    }
}

/// ✨ 单条书摘卡片组件：独立的毛玻璃材质，独自悬浮
struct ExcerptCardView: View {
    let content: String
    let createdAt: String
    @Environment(\.colorScheme) var colorScheme
    @State private var isHovered = false
    
    var body: some View {
        let isDark = colorScheme == .dark
        
        ZStack(alignment: .topLeading) {
            // 1. 独立的背景材质：bg-white/80 dark:bg-slate-900/60
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(isDark ? Color.twSlate900.opacity(0.6) : Color.white.opacity(0.8))
                .background(.ultraThinMaterial)
            
            // 2. 独立的动态边框：hover:border-indigo-300 dark:hover:border-slate-500
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(isHovered ? (isDark ? Color.twSlate500 : Color.twIndigo500.opacity(0.4)) : (isDark ? Color.twSlate700.opacity(0.5) : Color.white.opacity(0.8)), lineWidth: 1)
            
            // 3. 内容排版
            VStack(alignment: .leading, spacing: 20) {
                ZStack(alignment: .topLeading) {
                    // 左上角巨大的背景引号 (对应 text-6xl text-slate-200)
                    Text("\"")
                        .font(.system(size: 80, weight: .black, design: .serif))
                        .foregroundColor(isDark ? Color.twSlate700.opacity(0.3) : Color.twSlate200)
                        .offset(x: -10, y: -20)
                    
                    // 摘录正文
                    Text(content)
                        .font(.system(size: 18, weight: .regular, design: .serif))
                        .foregroundColor(isDark ? .twSlate200 : .twSlate700)
                        .lineSpacing(10)
                        .padding(.leading, 15)
                        .padding(.top, 10)
                }
                
                HStack {
                    Spacer()
                    Text("—— 记录于 \(createdAt)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(isDark ? .twSlate500 : .twSlate400)
                }
            }
            .padding(32)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        // ✨ 4. 独立悬浮阴影：自身产生的立体投影 (对应 shadow-xl dark:shadow-2xl)
        .shadow(color: Color.black.opacity(isDark ? (isHovered ? 0.4 : 0.25) : (isHovered ? 0.15 : 0.08)), radius: isHovered ? 25 : 15, y: isHovered ? 15 : 8)
        .offset(y: isHovered ? -4 : 0)
        .onHover { h in withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { isHovered = h } }
    }
}
