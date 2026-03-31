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
            
            // 2. 在这里批量预先装载你想要的模拟书籍
            let book1 = Book(title: "悉达多", author: "赫尔曼·黑塞", status: "READING", tags: ["哲学", "文学"])
            let book2 = Book(title: "百年孤独", author: "加西亚·马尔克斯", status: "READING", tags: ["魔幻现实"])
            let book3 = Book(title: "三体", author: "刘慈欣", status: "UNREAD", tags: ["科幻大作"])
            let book4 = Book(title: "人类简史", author: "尤瓦尔·赫拉利", status: "FINISHED", tags: ["历史"])
            
            // 插入到模拟数据库中
            container.mainContext.insert(book1)
            container.mainContext.insert(book2)
            container.mainContext.insert(book3)
            container.mainContext.insert(book4)
            
            return container
        } catch {
            fatalError("无法创建预览数据库: \(error)")
        }
    }()
    
    // 3. 提供一个便捷属性，方便在单一卡片预览时直接抓取第一本书
    static var mockBook: Book {
        let fetchDescriptor = FetchDescriptor<Book>()
        let books = try! shared.mainContext.fetch(fetchDescriptor)
        return books.first!
    }
}
