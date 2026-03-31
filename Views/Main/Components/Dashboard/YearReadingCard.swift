//
//  YearReadingCard.swift
//  MyLibrary
//
//  Created by akram on 2026/3/31.
//

import Foundation
import SwiftUI

struct YearReadingCard: View {
    let count: Int
    @State private var isHovered = false

    var body: some View {
        ZStack(alignment: .leading) {
            // 背景
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(Color(NSColor.windowBackgroundColor).opacity(0.4))
                .background(.ultraThinMaterial)

            // 线条网格纹理
            GridLineShape()
                .stroke(Color.indigo.opacity(0.2), lineWidth: 0.5)
                .mask(
                    RadialGradient(
                        colors: [.black, .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )

            // 动态光晕
            Circle()
                .fill(Color.indigo.opacity(0.8))
                .frame(width: 160, height: 160)
                .blur(radius: 50)
                .offset(x: isHovered ? 120 : 160, y: isHovered ? 60 : 100)

            VStack(alignment: .leading, spacing: 0) {
                Label("今年已读", systemImage: "book.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.indigo)
                    .tracking(2)

                Spacer()

                // 2. ✨ 核心数字区：强制居中
                HStack(alignment: .bottom, spacing: 6) {
                    Text("\(count)")
                        .font(
                            .system(size: 72, weight: .black, design: .rounded)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.primary, .indigo],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        // 增加一点发光感
                        .shadow(
                            color: Color.indigo.opacity(isHovered ? 0.4 : 0),
                            radius: 15,
                            x: 0,
                            y: 10
                        )

                    Text("本")
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(.indigo.opacity(0.6))
                        .padding(.bottom, 15)
                }
                .frame(maxWidth: .infinity, alignment: .center)  // ✨ 关键：强制在 VStack 中间对齐
                .scaleEffect(isHovered ? 1.05 : 1.0)

                Spacer()
            }
            .padding(24)
        }
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .onHover { h in withAnimation(.spring()) { isHovered = h } }
    }
}


#Preview("Light Mode") {
    YearReadingCard(count: 24)
        .frame(width: 280, height: 180)
        .padding()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    YearReadingCard(count: 24)
        .frame(width: 280, height: 180)
        .padding()
        .preferredColorScheme(.dark)
        .background(Color.black.ignoresSafeArea())
        
}
