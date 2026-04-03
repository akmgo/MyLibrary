import SwiftUI
import SwiftData

@main
struct MyLibraryApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1400, height: 950)
        #if os(macOS)
        // 允许用户自由缩放窗口，设置一个最小体验尺寸
        .windowResizability(.contentMinSize)
        #endif
        
        .modelContainer(for: [Book.self, Excerpt.self, ReadingRecord.self])
    }
}
