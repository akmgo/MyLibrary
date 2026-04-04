// Models/Book.swift
import Foundation
import SwiftData

@Model
final class Book {
    @Attribute(.unique) var id: String
    var title: String
    var author: String
    
    /// ✨ 只有这个字段负责存封面
    @Attribute(.externalStorage) var coverData: Data?
    
    var status: String
    var rating: Int
    var tags: [String]
    var startTime: Date?
    var endTime: Date?
    var progress: Int = 0
    var isWantToRead: Bool = false
    
    @Relationship(deleteRule: .cascade) var excerpts: [Excerpt]? = []
    @Relationship(deleteRule: .cascade) var reading_record: [ReadingRecord]? = []
    
    init(id: String = UUID().uuidString,
         title: String,
         author: String,
         coverData: Data? = nil,
         status: String = "UNREAD",
         rating: Int = 0,
         tags: [String] = [],
         startTime: Date? = nil,
         endTime: Date? = nil,
         progress: Int = 0,
         isWantToRead: Bool = false)
    {
        self.id = id
        self.title = title
        self.author = author
        self.coverData = coverData
        self.status = status
        self.rating = rating
        self.tags = tags
        self.startTime = startTime
        self.endTime = endTime
        self.progress = progress
        self.isWantToRead = false
    }
}
