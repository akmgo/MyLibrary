//
//  Excerpt.swift
//  MyLibrary
//
//  Created by akram on 2026/3/31.
//

import Foundation
import SwiftData

@Model
final class Excerpt {
    @Attribute(.unique) var id: String
    var content: String
    var pageOrChapter: String
    var createdAt: Date
    
    init(id: String = UUID().uuidString, content: String, pageOrChapter: String = "", createdAt: Date = Date()) {
        self.id = id
        self.content = content
        self.pageOrChapter = pageOrChapter
        self.createdAt = createdAt
    }
}
