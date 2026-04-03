//
//  PreviewData.swift
//  MyLibrary
//
//  Created by akram on 2026/3/31.
//

import Foundation
import SwiftUI
import SwiftData

/// 这是一个专门用于 Xcode 预览的全局内存数据库
@MainActor
class PreviewData {
    // 1. 创建全局唯一的模拟容器（只存在于内存中，不影响真实 App 数据）
    static let shared: ModelContainer = {
        let schema = Schema([Book.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        
        do {
            let container = try ModelContainer(for: schema, configurations: [config])
            let context = container.mainContext
            
            // 为了让“年度阅读轨迹”有数据，我们动态获取今年年份
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd"
            let currentYear = String(Calendar.current.component(.year, from: Date()))
            
            // 2. 批量装载模拟书籍 (加入了丰富的时间和评分数据，以便测试画廊和时间线)
            let book1 = Book(title: "悉达多", author: "赫尔曼·黑塞", status: "READING", tags: ["哲学", "文学"])
            
            let book2 = Book(title: "百年孤独", author: "加西亚·马尔克斯", status: "READING", tags: ["魔幻现实"])
            
            let book3 = Book(title: "三体", author: "刘慈欣", status: "UNREAD", tags: ["科幻大作"])
            
            let book4 = Book(title: "人类简史", author: "尤瓦尔·赫拉利", status: "FINISHED", rating: 4, tags: ["历史", "人类学"], startTime: formatter.date(from: "\(currentYear)/02/01"), endTime: formatter.date(from: "\(currentYear)/02/20"))
            
            let book5 = Book(title: "活着", author: "余华", status: "FINISHED", rating: 5, tags: ["经典"], startTime: formatter.date(from: "\(currentYear)/01/10"), endTime: formatter.date(from: "\(currentYear)/03/15"))
            
            let book6 = Book(title: "理想国", author: "柏拉图", status: "FINISHED", rating: 5, tags: ["哲学", "政治"], startTime: formatter.date(from: "\(currentYear)/04/01"), endTime: formatter.date(from: "\(currentYear)/04/10"))
            
            // 插入到模拟数据库中
            context.insert(book1)
            context.insert(book2)
            context.insert(book3)
            context.insert(book4)
            context.insert(book5)
            context.insert(book6)
            
            return container
        } catch {
            fatalError("无法创建预览数据库: \(error)")
        }
    }()
    
    // 3. 提供便捷属性：单一卡片预览时抓取第一本书
    static var mockBook: Book {
        let fetchDescriptor = FetchDescriptor<Book>()
        let books = try! shared.mainContext.fetch(fetchDescriptor)
        return books.first!
    }
    
    // 4. 新增便捷属性：画廊和时间线预览时，抓取所有书籍数组
    static var allMockBooks: [Book] {
        let fetchDescriptor = FetchDescriptor<Book>()
        return try! shared.mainContext.fetch(fetchDescriptor)
    }
}
