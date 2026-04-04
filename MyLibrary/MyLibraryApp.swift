import SwiftData
import SwiftUI

@main
struct MyLibraryApp: App {
    /// 自定义数据库容器配置
    var sharedModelContainer: ModelContainer = {
        // 1. 注册你的所有数据模型 (请确保这里包含了你所有的 Model)
        let schema = Schema([
            Book.self,
            Excerpt.self,
            ReadingRecord.self
        ])
            
        // 2. 指定你想要的绝对路径：这里我们把它放到 Mac 的「文稿 (Documents)」文件夹下的「MyLibraryData」目录里
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dbDirectory = documentDirectory.appendingPathComponent("MyLibraryData")
            
        // 3. 如果这个文件夹不存在，代码会自动帮你创建
        if !FileManager.default.fileExists(atPath: dbDirectory.path) {
            try? FileManager.default.createDirectory(at: dbDirectory, withIntermediateDirectories: true, attributes: nil)
        }
            
        // 4. 指定数据库文件的名字
        let dbURL = dbDirectory.appendingPathComponent("default.store")
            
        // 5. 应用配置
        let modelConfiguration = ModelConfiguration(schema: schema, url: dbURL)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("无法创建 ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1512, height: 1010)
        #if os(macOS)
        // 允许用户自由缩放窗口，设置一个最小体验尺寸
        .windowResizability(.contentMinSize)
        #endif
        
        .modelContainer(sharedModelContainer)
    }
}
