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
    var createdAt: Date
    
    var book: Book?
    
    init(id: String = UUID().uuidString, content: String, createdAt: Date = Date()) {
        self.id = id
        self.content = content
        self.createdAt = createdAt
    }
}
