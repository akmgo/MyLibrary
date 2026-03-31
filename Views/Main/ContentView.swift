import SwiftUI
import SwiftData

struct ContentView: View {
    @Namespace private var animationNamespace
    @State private var selectedBook: Book?
    
    var body: some View {
        ZStack {
            TabView {
                HomeView(namespace: animationNamespace, selectedBook: $selectedBook)
                    .tabItem { Label("我的书房", systemImage: "books.vertical") }
                
                ArchiveView(namespace: animationNamespace, selectedBook: $selectedBook)
                    .tabItem { Label("全景档案", systemImage: "sparkles.rectangle.stack") }
            }
            .tint(.indigo)
            
            // 详情页覆盖层
            if let book = selectedBook {
                BookDetailView(book: book, namespace: animationNamespace, selectedBook: $selectedBook)
                    .zIndex(1)
                    .transition(.asymmetric(
                        insertion: .opacity.animation(.easeIn(duration: 0.3)),
                        removal: .opacity.animation(.easeOut(duration: 0.3))
                    ))
            }
        }
    }
}

// ✨ 新增：全局导航预览
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Book.self, Excerpt.self, configurations: config)
    
    // 塞入测试数据
    let book = Book(title: "预览测试书籍", author: "测试作者", status: "READING", rating: 4, tags: ["测试"])
    container.mainContext.insert(book)
    
    return ContentView()
        .modelContainer(container)
}
