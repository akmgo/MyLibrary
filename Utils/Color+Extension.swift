//
//  Color+Extension.swift
//  MyLibrary
//
//  Created by akram on 2026/3/31.
//

import Foundation
import SwiftUI

extension Color {
    // ✨ 还原 Tailwind 中的 Emerald 500 (#10b981)
    static let emerald = Color(red: 16/255, green: 185/255, blue: 129/255)
    
    // ✨ 还原 Tailwind 中的 Sky 500 (#0ea5e9) - 用于能量矩阵
    static let sky = Color(red: 14/255, green: 165/255, blue: 233/255)
    
    // ✨ 还原 Tailwind 中的 Fuchsia 500 (#d946ef) - 用于进度条
    static let fuchsia = Color(red: 217/255, green: 70/255, blue: 239/255)
    
    // ✨ 还原 Tailwind 中的 Slate 500 (#64748b) - 用于次要文字
    static let slate = Color(red: 100/255, green: 116/255, blue: 139/255)
}
