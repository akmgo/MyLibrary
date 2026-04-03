import SwiftData
import SwiftUI

struct BookExcerptsView: View {
    let book: Book
    @Environment(\.colorScheme) var colorScheme
    @Binding var showAddExcerpt: Bool
    
    private var sortedExcerpts: [Excerpt] {
        let list = book.excerpts ?? []
        return list.sorted { $0.createdAt > $1.createdAt }
    }
    
    var body: some View {
        let isDark = colorScheme == .dark
        VStack(alignment: .leading, spacing: 30) {
            // 1. 顶部标题栏
            VStack(spacing: 16) {
                HStack(alignment: .center) {
                    Text("摘录与笔记").font(.system(size: 32, weight: .bold, design: .rounded)).foregroundColor(isDark ? .white : .twSlate800)
                    Spacer()
                    DetailAddExcerptButton {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) { showAddExcerpt = true }
                    }
                }
                Divider().background(isDark ? Color.twSlate800 : Color.twSlate200)
            }
            
            // 2. 书摘流列表
            if sortedExcerpts.isEmpty {
                VStack(spacing: 12) {
                    Text("这本书还没有留下任何思考的痕迹").font(.system(size: 18)).foregroundColor(isDark ? .twSlate400 : .twSlate500)
                    Text("点击右上角按钮，记录下你的第一条摘录").font(.system(size: 14)).foregroundColor(isDark ? .twSlate600 : .twSlate400)
                }
                .frame(maxWidth: .infinity).frame(height: 240)
                .background(isDark ? Color.twSlate900.opacity(0.3) : Color.white.opacity(0.4)).background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(isDark ? Color.twSlate800 : Color.twSlate300, style: StrokeStyle(lineWidth: 1, dash: [6, 6])))
            } else {
                let columns = [GridItem(.adaptive(minimum: 350), spacing: 24)]
                LazyVGrid(columns: columns, spacing: 24) {
                    ForEach(sortedExcerpts, id: \.id) { excerpt in
                        ExcerptCardView(content: excerpt.content, createdAt: formatDate(excerpt.createdAt))
                    }
                }
            }
        }.padding(.top, 20)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - 专属私有组件 (避免污染全局)
private struct ExcerptCardView: View {
    let content: String
    let createdAt: String
    @Environment(\.colorScheme) var colorScheme
    @State private var isHovered = false
    
    var body: some View {
        let isDark = colorScheme == .dark
        
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(isDark ? Color.twSlate900.opacity(0.6) : Color.white.opacity(0.8)).background(.ultraThinMaterial)
            
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(isHovered ? (isDark ? Color.twSlate500 : Color.twIndigo500.opacity(0.4)) : (isDark ? Color.twSlate700.opacity(0.5) : Color.white.opacity(0.8)), lineWidth: 1)
            
            VStack(alignment: .leading, spacing: 20) {
                ZStack(alignment: .topLeading) {
                    Text("\"").font(.system(size: 80, weight: .black, design: .serif)).foregroundColor(isDark ? Color.twSlate700.opacity(0.3) : Color.twSlate200).offset(x: -10, y: -20)
                    Text(content).font(.system(size: 18, weight: .regular, design: .serif)).foregroundColor(isDark ? .twSlate200 : .twSlate700).lineSpacing(10).padding(.leading, 15).padding(.top, 10)
                }
                HStack {
                    Spacer()
                    Text("—— 记录于 \(createdAt)").font(.system(size: 14, weight: .medium)).foregroundColor(isDark ? .twSlate500 : .twSlate400)
                }
            }.padding(32)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(isDark ? (isHovered ? 0.4 : 0.25) : (isHovered ? 0.15 : 0.08)), radius: isHovered ? 25 : 15, y: isHovered ? 15 : 8)
        .offset(y: isHovered ? -4 : 0)
        .onHover { h in withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { isHovered = h } }
    }
}
