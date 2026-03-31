//
//  DashboardUtils.swift
//  MyLibrary
//
//  Created by akram on 2026/3/31.
//

import Foundation

import SwiftUI

// 线型网格
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

// 点型网格
struct GridDotShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let step: CGFloat = 16
        for x in stride(from: 0, through: rect.width, by: step) {
            for y in stride(from: 0, through: rect.height, by: step) {
                path.addEllipse(in: CGRect(x: x, y: y, width: 1.5, height: 1.5))
            }
        }
        return path
    }
}
