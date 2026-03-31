import SwiftUI
import SwiftData

struct YearlyTimelineView: View {
    @Query(filter: #Predicate<Book> { $0.status == "FINISHED" }, sort: \Book.endTime, order: .reverse)
    var finishedBooks: [Book]
    
    var namespace: Namespace.ID
    @Binding var selectedBook: Book?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                VStack(spacing: 8) {
                    Text("\(Calendar.current.component(.year, from: Date())) 阅读轨迹")
                        .font(.largeTitle).bold()
                    
                    Text("\(finishedBooks.count) 本")
                        .font(.headline)
                        .foregroundColor(.indigo)
                        .padding(.horizontal, 16).padding(.vertical, 6)
                        .background(Color.indigo.opacity(0.1))
                        .clipShape(Capsule())
                }
                .padding(.top, 40)
                
                if finishedBooks.isEmpty {
                    ContentUnavailableView("今年还没有读完的书籍", systemImage: "calendar.badge.exclamationmark")
                        .padding(.top, 50)
                } else {
                    ZStack(alignment: .top) {
                        Rectangle()
                            .fill(LinearGradient(colors: [.indigo.opacity(0.2), .indigo.opacity(0.8), .clear], startPoint: .top, endPoint: .bottom))
                            .frame(width: 4)
                        
                        VStack(spacing: 0) {
                            ForEach(Array(finishedBooks.enumerated()), id: \.element.id) { index, book in
                                let isLeft = index % 2 == 0
                                
                                HStack {
                                    if isLeft {
                                        TimelineItemCard(book: book, isLeft: true, namespace: namespace, selectedBook: $selectedBook)
                                        Spacer(minLength: 20)
                                        Color.clear.frame(maxWidth: .infinity)
                                    } else {
                                        Color.clear.frame(maxWidth: .infinity)
                                        Spacer(minLength: 20)
                                        TimelineItemCard(book: book, isLeft: false, namespace: namespace, selectedBook: $selectedBook)
                                    }
                                }
                                .padding(.vertical, 30)
                                .padding(.horizontal, 20)
                                .overlay(
                                    Circle()
                                        .fill(.white)
                                        .stroke(Color.indigo, lineWidth: 4)
                                        .frame(width: 16, height: 16)
                                        .shadow(color: .indigo.opacity(0.5), radius: 5)
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}

struct TimelineItemCard: View {
    let book: Book
    let isLeft: Bool
    let namespace: Namespace.ID
    @Binding var selectedBook: Book?
    
    var body: some View {
        HStack(spacing: 16) {
            if isLeft {
                VStack(alignment: .trailing, spacing: 4) {
                    Text(book.title).font(.headline).bold().multilineTextAlignment(.trailing)
                    Text(book.author).font(.subheadline).foregroundColor(.secondary)
                    if let date = book.endTime {
                        Text(date, format: .dateTime.month().day()).font(.caption).bold().foregroundColor(.indigo)
                    }
                }
                coverView
            } else {
                coverView
                VStack(alignment: .leading, spacing: 4) {
                    Text(book.title).font(.headline).bold().multilineTextAlignment(.leading)
                    Text(book.author).font(.subheadline).foregroundColor(.secondary)
                    if let date = book.endTime {
                        Text(date, format: .dateTime.month().day()).font(.caption).bold().foregroundColor(.indigo)
                    }
                }
            }
        }
        .padding()
        .glassEffect(cornerRadius: 20)
        .onTapGesture {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                selectedBook = book
            }
        }
    }
    
    private var coverView: some View {
        LocalCoverView(coverData: book.coverData, fallbackTitle: book.title)
            .frame(width: 80, height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 5)
            .matchedGeometryEffect(id: "card-\(book.id)", in: namespace, isSource: selectedBook?.id != book.id)
    }
}

// ✨ 新增：时间轴预览
#Preview {
    struct TimelinePreviewWrapper: View {
        @Namespace var namespace
        @State var selectedBook: Book?
        var body: some View {
            YearlyTimelineView(namespace: namespace, selectedBook: $selectedBook)
        }
    }
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Book.self, configurations: config)
    
    container.mainContext.insert(Book(title: "论美国的民主", author: "托克维尔", status: "FINISHED", endTime: Date()))
    container.mainContext.insert(Book(title: "万历十五年", author: "黄仁宇", status: "FINISHED", endTime: Date().addingTimeInterval(-86400)))
    
    return TimelinePreviewWrapper().modelContainer(container)
}
