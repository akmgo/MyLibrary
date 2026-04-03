//
//  GlassModifier.swift
//  MyLibrary
//
//  Created by akram on 2026/3/31.
//

import SwiftUI

struct GlassModifier: ViewModifier {
    var cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            // 1. 苹果原生极薄毛玻璃材质
            .background(.ultraThinMaterial)
            // 2. 平滑圆角
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            // 3. 玻璃高光反光边缘
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        .linearGradient(
                            colors: [.white.opacity(0.6), .clear, .white.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            // 4. 原生环境光阴影
            .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 10)
    }
}

// 扩展 View，方便后续像 CSS 一样链式调用
extension View {
    func glassEffect(cornerRadius: CGFloat = 24) -> some View {
        self.modifier(GlassModifier(cornerRadius: cornerRadius))
    }
}
