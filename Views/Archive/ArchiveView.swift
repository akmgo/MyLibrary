import SwiftUI
import SwiftData

struct ArchiveView: View {
    @Query(filter: #Predicate<Book> { $0.status == "FINISHED" }) var finishedBooks: [Book]
    
    var namespace: Namespace.ID
    @Binding var selectedBook: Book?
    
    @State private var currentIndex: Int = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.indigo.opacity(0.1), .purple.opacity(0.15)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                if finishedBooks.isEmpty {
                    Text("暂无已读档案").foregroundColor(.secondary)
                } else {
                    GeometryReader { geometry in
                        let width = geometry.size.width
                        let itemWidth: CGFloat = 200
                        
                        HStack(spacing: 0) {
                            ForEach(Array(finishedBooks.enumerated()), id: \.element.id) { index, book in
                                ArchiveCarouselItem(book: book, index: index, currentIndex: currentIndex, namespace: namespace, selectedBook: selectedBook)
                                    .frame(width: itemWidth, height: 300)
                                    .rotation3DEffect(
                                        .degrees(Double(index - currentIndex) * -35),
                                        axis: (x: 0, y: 1, z: 0),
                                        perspective: 0.5
                                    )
                                    .scaleEffect(index == currentIndex ? 1.0 : 0.85)
                                    .opacity(index == currentIndex ? 1.0 : 0.5)
                                    .zIndex(index == currentIndex ? 10 : 0)
                                    .onTapGesture {
                                        if index == currentIndex {
                                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                                selectedBook = book
                                            }
                                        } else {
                                            withAnimation(.easeInOut(duration: 0.4)) {
                                                currentIndex = index
                                            }
                                        }
                                    }
                            }
                        }
                        .frame(width: width, alignment: .leading)
                        .offset(x: CGFloat(currentIndex) * -itemWidth + (width - itemWidth) / 2)
                        .gesture(
                            DragGesture().onEnded { value in
                                let threshold: CGFloat = 50
                                if value.translation.width < -threshold {
                                    withAnimation(.easeInOut) { currentIndex = min(currentIndex + 1, finishedBooks.count - 1) }
                                } else if value.translation.width > threshold {
                                    withAnimation(.easeInOut) { currentIndex = max(currentIndex - 1, 0) }
                                }
                            }
                        )
                    }
                    .frame(height: 400)
                }
            }
            .navigationTitle("全景档案")
        }
    }
}

struct ArchiveCarouselItem: View {
    let book: Book
    let index: Int
    let currentIndex: Int
    let namespace: Namespace.ID
    let selectedBook: Book?
    
    var body: some View {
        ZStack {
            LocalCoverView(coverData: book.coverData, fallbackTitle: book.title)
            
            RoundedRectangle(cornerRadius: 20)
                .stroke(LinearGradient(colors: [.white.opacity(0.6), .clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
        }
        .frame(width: 200, height: 300)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 10)
        .matchedGeometryEffect(
            id: index == currentIndex ? "card-\(book.id)" : "dummy-\(book.id)",
            in: namespace,
            isSource: selectedBook?.id != book.id
        )
    }
}

// ✨ 新增：3D 档案室预览
#Preview {
    struct ArchivePreviewWrapper: View {
        @Namespace var namespace
        @State var selectedBook: Book?
        var body: some View {
            ArchiveView(namespace: namespace, selectedBook: $selectedBook)
        }
    }
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Book.self, configurations: config)
    
    container.mainContext.insert(Book(title: "百年孤独", author: "马尔克斯", status: "FINISHED"))
    container.mainContext.insert(Book(title: "活着", author: "余华", status: "FINISHED"))
    container.mainContext.insert(Book(title: "悉达多", author: "黑塞", status: "FINISHED"))
    
    return ArchivePreviewWrapper().modelContainer(container)
}
