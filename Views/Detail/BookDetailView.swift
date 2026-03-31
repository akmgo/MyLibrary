import SwiftUI
import SwiftData

struct BookDetailView: View {
    let book: Book
    let namespace: Namespace.ID
    @Binding var selectedBook: Book?
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    HStack {
                        Button(action: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                selectedBook = nil
                            }
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.title3).bold()
                                .foregroundColor(.primary)
                                .padding(12)
                                .background(.thinMaterial)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 60)
                    
                    LocalCoverView(coverData: book.coverData, fallbackTitle: book.title)
                    .frame(width: 260, height: 390)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .shadow(color: .black.opacity(0.4), radius: 25, x: 0, y: 15)
                    .matchedGeometryEffect(id: "card-\(book.id)", in: namespace)

                    BookDossierView(book: book)
                        .padding(.horizontal, 20)
                }
                .padding(.bottom, 40)
            }
            .ignoresSafeArea()
        }
    }
}

// ✨ 新增：详情页预览
#Preview {
    struct DetailPreviewWrapper: View {
        @Namespace var namespace
        @State var selectedBook: Book?
        var body: some View {
            let book = Book(title: "人类简史", author: "赫拉利", status: "READING", rating: 4, tags: ["历史", "人类学"])
            BookDetailView(book: book, namespace: namespace, selectedBook: $selectedBook)
        }
    }
    return DetailPreviewWrapper()
}
