//
//  DashboardStatCard.swift
//  MyLibrary
//
//  Created by akram on 2026/3/31.
//

import Foundation

import SwiftUI

struct DashboardStatCard: View {
    let title: String
    let value: Int
    let unit: String
    let icon: String
    let mainColor: Color
    let gridType: GridType
    
    enum GridType { case line, dot }
    @State private var isHovered = false

    var body: some View {
        ZStack(alignment: .leading) {
            // 背景材质
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(NSColor.windowBackgroundColor).opacity(0.4))
                .background(.ultraThinMaterial)
            
            // 1. 纯 CSS 风格网格纹理
            Group {
                if gridType == .line {
                    GridLineShape() // 自定义线型网格
                        .stroke(mainColor.opacity(0.1), lineWidth: 0.5)
                } else {
                    GridDotShape() // 自定义点型网格
                        .fill(mainColor.opacity(0.2))
                }
            }
            .mask(RadialGradient(gradient: Gradient(colors: [.black, .clear]), center: .center, startRadius: 0, endRadius: 200))
            
            // 2. 悬浮光晕
            Circle()
                .fill(mainColor.opacity(0.3))
                .frame(width: 150, height: 150)
                .blur(radius: 50)
                .offset(x: isHovered ? 100 : 150, y: isHovered ? 80 : 120)
            
            // 3. 内容
            VStack(alignment: .leading, spacing: 15) {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                    Text(title)
                }
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(mainColor)
                .tracking(2)
                
                Spacer()
                
                HStack(alignment: .bottom, spacing: 4) {
                    Text("\(value)")
                        .font(.system(size: 64, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(colors: [.primary, mainColor], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .shadow(color: mainColor.opacity(0.3), radius: 10, x: 0, y: 10)
                    
                    Text(unit)
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(mainColor.opacity(0.6))
                        .padding(.bottom, 12)
                }
                .scaleEffect(isHovered ? 1.05 : 1.0)
            }
            .padding(24)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .onHover { hovering in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { isHovered = hovering }
        }
    }
}

// 线型网格绘制
struct GridLineShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let step: CGFloat = 20
        for x in stride(from: 0, through: rect.width, by: step) {
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: rect.height))
        }
        for y in stride(from: 0, through: rect.height, by: step) {
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: rect.width, y: y))
        }
        return path
    }
}

// 点型网格绘制
struct GridDotShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let step: CGFloat = 16
        for x in stride(from: 0, through: rect.width, by: step) {
            for y in stride(from: 0, through: rect.height, by: step) {
                path.addEllipse(in: CGRect(x: x, y: y, width: 1, height: 1))
            }
        }
        return path
    }
}
