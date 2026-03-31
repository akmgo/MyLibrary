//
//  WeeklyEnergyMatrix.swift
//  MyLibrary
//
//  Created by akram on 2026/3/31.
//

import Foundation


import SwiftUI

struct WeeklyEnergyMatrix: View {
    let continuousDays: Int
    let weekData: [Bool] // true 为已读
    let days = ["一", "二", "三", "四", "五", "六", "日"]
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(NSColor.windowBackgroundColor).opacity(0.4))
                .background(.ultraThinMaterial)
            
            VStack(spacing: 20) {
                // 头部
                HStack {
                    Label("本周能量矩阵", systemImage: "sparkles")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.blue)
                    Spacer()
                    HStack {
                        Circle().fill(.blue).frame(width: 6, height: 6).blur(radius: 1)
                        Text("已充能 \(continuousDays)/7").font(.caption2).bold()
                    }
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(Color.blue.opacity(0.1)).clipShape(Capsule())
                }
                
                // 能量矩阵
                HStack(spacing: 12) {
                    ForEach(0..<7, id: \.self) { index in
                        VStack(spacing: 10) {
                            Text(days[index])
                                .font(.system(size: 12, weight: .black))
                                .foregroundColor(.secondary)
                            
                            // 能量胶囊
                            EnergyPill(isActive: weekData[index])
                        }
                    }
                }
            }
            .padding(24)
        }
    }
}

struct EnergyPill: View {
    let isActive: Bool
    
    var body: some View {
        ZStack(alignment: .top) {
            Capsule()
                .fill(isActive ? AnyShapeStyle(LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom)) : AnyShapeStyle(Color.gray.opacity(0.1)))
                .frame(width: 30, height: 50)
                .overlay(Capsule().stroke(isActive ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 1))
            
            if isActive {
                // 顶部高光
                Capsule()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: 15, height: 4)
                    .blur(radius: 1)
                    .padding(.top, 4)
                
                // 中心指示核
                Circle()
                    .fill(.white)
                    .frame(width: 6, height: 6)
                    .shadow(color: .white, radius: 4)
                    .offset(y: 35)
            }
        }
        .scaleEffect(isActive ? 1.1 : 1.0)
    }
}
