import SwiftUI
import SwiftData
import UniformTypeIdentifiers // ✨ 修复：去掉 internal

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(filter: #Predicate<Book> { $0.status == "READING" }) var readingBooks: [Book]
    @Query(filter: #Predicate<Book> { $0.status == "UNREAD" }) var unreadBooks: [Book]
    @Query var allBooks: [Book]
    
    var namespace: Namespace.ID
    @Binding var selectedBook: Book?
    
    @State private var isImporterPresented = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.blue.opacity(0.1), .purple.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        if readingBooks.isEmpty && unreadBooks.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "books.vertical")
                                    .font(.system(size: 50))
                                    .foregroundColor(.secondary.opacity(0.5))
                                Text("书房空空如也\n请点击右上角的 🔄 按钮加载基础数据")
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 100)
                        } else {
                            if let heroBook = readingBooks.first {
                                Text("当前在读").font(.title2).bold().padding(.horizontal)
                                BookCardView(title: heroBook.title, author: heroBook.author, coverData: heroBook.coverData, tags: heroBook.tags, rating: heroBook.rating)
                                    .padding(.horizontal)
                                    .matchedGeometryEffect(id: "card-\(heroBook.id)", in: namespace, isSource: selectedBook?.id != heroBook.id)
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { selectedBook = heroBook }
                                    }
                            }
                            
                            if !unreadBooks.isEmpty {
                                Text("待读列表").font(.title2).bold().padding(.horizontal).padding(.top, 16)
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))], spacing: 16) {
                                    ForEach(unreadBooks) { book in
                                        BookCardView(title: book.title, author: book.author, coverData: book.coverData, tags: book.tags, rating: book.rating)
                                            .matchedGeometryEffect(id: "card-\(book.id)", in: namespace, isSource: selectedBook?.id != book.id)
                                            .onTapGesture {
                                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { selectedBook = book }
                                            }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("我的书房")
        }
    }
}

// ✨ 新增：为了在预览中提供 Namespace，我们需要写一个包装器
#Preview {
    struct HomePreviewWrapper: View {
        @Namespace var namespace
        @State var selectedBook: Book?
        
        var body: some View {
            HomeView(namespace: namespace, selectedBook: $selectedBook)
        }
    }
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Book.self, configurations: config)
    
    // 注入两条假数据以供预览
    container.mainContext.insert(Book(title: "在读书籍", author: "作者A", status: "READING", rating: 4, tags: ["科幻"]))
    container.mainContext.insert(Book(title: "待读书籍", author: "作者B", status: "UNREAD", tags: ["历史"]))
    
    return HomePreviewWrapper()
        .modelContainer(container)
}
