//
//  MonthReadingCard.swift
//  MyLibrary
//
//  Created by akram on 2026/3/31.
//

import Foundation
import SwiftUI

struct MonthReadingCard: View {
    let days: Int
    @State private var isHovered = false

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(Color(NSColor.windowBackgroundColor).opacity(0.4))
                .background(.ultraThinMaterial)

            // 点阵纹理
            GridDotShape()
                .fill(Color.emerald.opacity(0.9))
                .mask(RadialGradient(colors: [.black, .clear], center: .center, startRadius: 0, endRadius: 180))

            Circle()
                .fill(Color.emerald.opacity(0.8))
                .frame(width: 160, height: 160)
                .blur(radius: 50)
                .offset(x: isHovered ? -50 : -80, y: isHovered ? -50 : -80)

            VStack(alignment: .leading, spacing: 0) {
                Label("本月共鸣", systemImage: "calendar")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.emerald)
                    .tracking(2)

                Spacer()

                // 2. ✨ 核心数字区：强制居中
                HStack(alignment: .bottom, spacing: 6) {
                    Text("\(days)")
                        .font(.system(size: 72, weight: .black, design: .rounded))
                        .foregroundStyle(LinearGradient(colors: [.primary, .emerald], startPoint: .top, endPoint: .bottom))
                        .shadow(color: Color.emerald.opacity(isHovered ? 0.4 : 0), radius: 15, x: 0, y: 10)

                    Text("天")
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(.emerald.opacity(0.6))
                        .padding(.bottom, 15)
                }
                .frame(maxWidth: .infinity, alignment: .center) // ✨ 关键：水平居中
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
    MonthReadingCard(days: 15)
        .frame(width: 280, height: 180)
        .padding()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    MonthReadingCard(days: 15)
        .frame(width: 280, height: 180)
        .padding()
        .preferredColorScheme(.dark)
        .background(Color.black.ignoresSafeArea())
        
}
