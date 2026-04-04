// Utils/Color+Extension.swift
import SwiftUI

extension Color {
    /// 统一的 16 进制颜色解析器
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }

    // 基础色板
    static let twSlate50 = Color(red: 248/255, green: 250/255, blue: 252/255)
    static let twSlate100 = Color(red: 241/255, green: 245/255, blue: 249/255)
    static let twSlate200 = Color(red: 226/255, green: 232/255, blue: 240/255)
    static let twSlate300 = Color(red: 203/255, green: 213/255, blue: 225/255)
    static let twSlate400 = Color(red: 148/255, green: 163/255, blue: 184/255)
    static let twSlate500 = Color(red: 100/255, green: 116/255, blue: 139/255)
    static let twSlate600 = Color(red: 71/255, green: 85/255, blue: 105/255)
    static let twSlate700 = Color(red: 51/255, green: 65/255, blue: 85/255)
    static let twSlate800 = Color(red: 30/255, green: 41/255, blue: 59/255)
    static let twSlate900 = Color(red: 15/255, green: 23/255, blue: 42/255)
    static let twSlate950 = Color(red: 2/255, green: 6/255, blue: 23/255)

    // 主题色板
    static let twSky300 = Color(red: 125/255, green: 211/255, blue: 252/255)
    static let twSky400 = Color(red: 56/255, green: 189/255, blue: 248/255)
    static let twSky500 = Color(red: 14/255, green: 165/255, blue: 233/255)
    static let twSky600 = Color(red: 2/255, green: 132/255, blue: 199/255)
    static let twSky700 = Color(red: 3/255, green: 105/255, blue: 161/255)

    static let twEmerald400 = Color(red: 52/255, green: 211/255, blue: 153/255)
    static let twEmerald500 = Color(red: 16/255, green: 185/255, blue: 129/255)

    static let twFuchsia300 = Color(red: 240/255, green: 171/255, blue: 252/255)
    static let twFuchsia500 = Color(red: 217/255, green: 70/255, blue: 239/255)

    static let twPurple300 = Color(red: 216/255, green: 180/255, blue: 254/255)
    static let twPurple600 = Color(red: 147/255, green: 51/255, blue: 234/255)

    static let twBlue300 = Color(red: 147/255, green: 197/255, blue: 253/255)
    static let twBlue600 = Color(red: 37/255, green: 99/255, blue: 235/255)

    static let twOrange500 = Color(red: 249/255, green: 115/255, blue: 22/255)

    /// ✨ 补上缺失的暖阳光晕颜色
    static let twAmber200 = Color(red: 253/255, green: 230/255, blue: 138/255)

    // 在主题色板中追加以下颜色：
    static let twEmerald600 = Color(red: 5/255, green: 150/255, blue: 105/255)
    static let twIndigo50 = Color(hex: "EEF2FF")
    static let twIndigo100 = Color(hex: "E0E7FF")
    static let twIndigo200 = Color(hex: "C7D2FE")
    static let twIndigo300 = Color(hex: "A5B4FC")
    static let twIndigo400 = Color(hex: "818CF8")
    static let twIndigo500 = Color(hex: "6366F1")
    static let twIndigo600 = Color(hex: "4F46E5")
    static let twIndigo700 = Color(hex: "4338CA")
    static let twIndigo800 = Color(hex: "3730A3")
    static let twIndigo900 = Color(hex: "312E81")
    static let twIndigo950 = Color(hex: "1E1B4B")

    // ✨ 补齐 Apple Music 流体引擎需要的色阶
    static let twPurple500 = Color(hex: "a855f7")
    static let twFuchsia400 = Color(hex: "e879f9")

    static let twPurple400 = Color(hex: "c084fc")

    /// Teal (蓝绿/青色系列)
    static let twTeal600 = Color(hex: "0d9488")

    /// Fuchsia (洋红系列补充)
    static let twFuchsia600 = Color(hex: "c026d3")

    /// Tailwind Purple 200 (#e9d5ff) - 用于浅色模式下的柔和紫光
    static let twPurple200 = Color(red: 233/255, green: 213/255, blue: 255/255)

    /// Tailwind Purple 900 (#581c87) - 用于深色模式下的深邃紫底
    static let twPurple900 = Color(red: 88/255, green: 28/255, blue: 135/255)

    /// Tailwind Fuchsia 900 (#701a75) - 用于深色模式下的暗粉色能量点
    static let twFuchsia900 = Color(red: 112/255, green: 26/255, blue: 117/255)

    /// Tailwind Sky 900 (#0c4a6e) - 用于深色模式下的深海蓝过渡
    static let twSky900 = Color(red: 12/255, green: 74/255, blue: 110/255)

    /// Tailwind Purple 800 (#6b21a8) - 介于 700 和 900 之间，非常饱满的深紫色
    static let twPurple800 = Color(red: 107/255, green: 33/255, blue: 168/255)

    /// Tailwind Fuchsia 800 (#86198f) - 带有强烈品红倾向的深暗色，用来做霓虹暗光绝佳
    static let twFuchsia800 = Color(red: 134/255, green: 25/255, blue: 143/255)
    /// Tailwind Fuchsia 700 (#a21caf) - 极具活力的亮品红色，适合做高光、进度条或热力图高频点
        static let twFuchsia700 = Color(red: 162/255, green: 28/255, blue: 175/255)
}
