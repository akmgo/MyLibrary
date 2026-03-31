import SwiftUI
import SwiftData

@main
struct MyLibraryApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Book.self, Excerpt.self])
    }
}
