import SwiftUI
import SwiftData

struct HeroBookCard: View {
    let book: Book
    let namespace: Namespace.ID
    @Binding var selectedBook: Book?
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
                    Circle().fill(Color.twIndigo500.opacity(isHovered ? 0.3 : 0.1)).frame(width: 100, height: 100).blur(radius: 30).offset(x: 20, y: 20)
                    LocalCoverView(coverData: book.coverData, fallbackTitle: book.title)
                        .frame(width: 110, height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .rotation3DEffect(.degrees(isHovered ? 12 : 0), axis: (x: 0, y: 1, z: -0.2), perspective: 0.5)
                        .offset(y: isHovered ? -8 : 0)
                        .shadow(color: Color.black.opacity(isHovered ? 0.3 : 0.1), radius: isHovered ? 15 : 5, x: 0, y: isHovered ? 10 : 5)
                        .matchedGeometryEffect(id: "card-\(book.id)", in: namespace, isSource: selectedBook?.id != book.id)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(book.title).font(.system(size: 26, weight: .black)).foregroundColor(isHovered ? .twIndigo500 : .primary).lineLimit(2)
                        Text(book.author).font(.title3).fontWeight(.bold).foregroundColor(.twSlate500).lineLimit(1)
                    }
                    .offset(x: isHovered ? 8 : 0)
                    Spacer()
                    HStack(alignment: .bottom) {
                        Spacer()
                        ZStack {
                            Circle().fill(Color.twIndigo500.opacity(isHovered ? 0.2 : 0)).frame(width: 60, height: 60).scaleEffect(isHovered ? 1.5 : 1).blur(radius: 10)
                            Image(systemName: "book.pages.fill").font(.system(size: 50)).foregroundColor(isHovered ? .twIndigo500 : .twSlate400.opacity(0.5)).rotationEffect(.degrees(isHovered ? -10 : 0)).scaleEffect(isHovered ? 1.2 : 1)
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
        .onHover { hovering in withAnimation(.interpolatingSpring(stiffness: 100, damping: 15)) { isHovered = hovering } }
        .onTapGesture { withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { selectedBook = book } }
    }
}

// ✨ 支持深浅色模式的独立预览
#Preview("Light Mode") {
    @Previewable @State var selectedBook: Book? = nil
    @Previewable @Namespace var namespace
    HeroBookCard(
        book: Book(title: "百年孤独", author: "马尔克斯"),
        namespace: namespace,
        selectedBook: $selectedBook
    )
    .frame(width: 300, height: 200)
    .padding()
    .preferredColorScheme(.light) // 强制浅色
}

#Preview("Dark Mode") {
    @Previewable @State var selectedBook: Book? = nil
    @Previewable @Namespace var namespace
    HeroBookCard(
        book: Book(title: "百年孤独", author: "马尔克斯"),
        namespace: namespace,
        selectedBook: $selectedBook
    )
    .frame(width: 300, height: 200)
    .padding()
    .preferredColorScheme(.dark) // 强制深色
    .background(Color.black.ignoresSafeArea()) // 给深色模式垫一个纯黑背景便于观察边框发光
}
