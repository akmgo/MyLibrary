import SwiftData
import SwiftUI

struct HeroBookCard: View {
    let book: Book
    let namespace: Namespace.ID
    @Binding var selectedBook: Book?
    // ✨ 接收 ID
    @Binding var activeCoverID: String
    @State private var isHovered = false
    
    var body: some View {
        ZStack(alignment: .leading) {
            GeometryReader { geo in
                Rectangle()
                    .fill(LinearGradient(colors: [.clear, .white.opacity(0.4), .clear], startPoint: .leading, endPoint: .trailing))
                    .frame(width: 100)
                    .rotationEffect(.degrees(15))
                    .offset(x: isHovered ? geo.size.width + 50 : -150)
            }
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            
            HStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(Color.twIndigo500.opacity(isHovered ? 0.3 : 0.1))
                        .frame(width: 100, height: 100)
                        .blur(radius: 30)
                        .offset(x: 20, y: 20)
                    
                    // ✨ 核心修复：同样采用 if-else 替身法，并严格规范修饰符顺序！
                    if selectedBook?.id != book.id {
                        LocalCoverView(coverData: book.coverData, fallbackTitle: book.title)
                            // 2. 切圆角
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            // 3. ✨ 黄金法则：挂载引擎
                            .matchedGeometryEffect(id: "hero-\(book.id)", in: namespace)
                            .frame(width: 110, height: 160)
                            // 4. 3D 旋转等形变必须放在引擎之后，否则起飞会扭曲！
                            .rotation3DEffect(.degrees(isHovered ? 12 : 0), axis: (x: 0, y: 1, z: -0.2), perspective: 0.5)
                            .offset(y: isHovered ? -8 : 0)
                            .shadow(color: Color.black.opacity(isHovered ? 0.3 : 0.1), radius: isHovered ? 15 : 5, x: 0, y: isHovered ? 10 : 5)
                    } else {
                        // 👉 替身：占据同等位置，但完全透明，且没有 3D 旋转的干扰
                        LocalCoverView(coverData: book.coverData, fallbackTitle: book.title)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .frame(width: 110, height: 160)
                            .opacity(0.001)
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(book.title)
                            .font(.system(size: 26, weight: .black))
                            .foregroundColor(isHovered ? .twIndigo500 : .primary)
                            .lineLimit(2)
                        Text(book.author)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.twSlate500)
                            .lineLimit(1)
                    }
                    .offset(x: isHovered ? 8 : 0)
                    
                    Spacer()
                    
                    HStack(alignment: .bottom) {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(Color.twIndigo500.opacity(isHovered ? 0.2 : 0))
                                .frame(width: 60, height: 60)
                                .scaleEffect(isHovered ? 1.5 : 1)
                                .blur(radius: 10)
                            Image(systemName: "book.pages.fill")
                                .font(.system(size: 50))
                                .foregroundColor(isHovered ? .twIndigo500 : .twSlate400.opacity(0.5))
                                .rotationEffect(.degrees(isHovered ? -10 : 0))
                                .scaleEffect(isHovered ? 1.2 : 1)
                        }
                    }
                    .offset(y: isHovered ? -4 : 0)
                }
                .padding(.vertical, 10)
            }
            .padding(24)
        }
        .contentShape(Rectangle())
        .innerGlassCardStyle(isHovered: isHovered)
        .onHover { hovering in
            withAnimation(.interpolatingSpring(stiffness: 100, damping: 15)) { isHovered = hovering }
        }
        .onTapGesture {
            activeCoverID = "hero-\(book.id)"
            // ✨ 加长响应时间，让长抛物线优美可见
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                selectedBook = book
            }
        }
    }
}
