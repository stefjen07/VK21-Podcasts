//
//  PieChart.swift
//  PieChart
//
//  Created by Евгений on 14.08.2021.
//

import SwiftUI

struct PieSliceData {
    var startAngle: Angle
    var endAngle: Angle
    var color: Color
}

struct PieSliceView: View {
    var pieSliceData: PieSliceData
    var borderColor: Color
    var selfSize: CGFloat
    
    var path: Path {
        var path = Path()
        let center = CGPoint(x: selfSize * 0.5, y: selfSize * 0.5)
        path.addArc(center: center, radius: center.x, startAngle: Angle(degrees: -90.0) + pieSliceData.startAngle, endAngle: Angle(degrees: -90.0) + pieSliceData.endAngle, clockwise: false)
        path.addLine(to: center)
        path.closeSubpath()
        return path
    }
    
    var body: some View {
        path
            .fill(pieSliceData.color)
            .overlay(path.stroke(borderColor, lineWidth: 3))
    }
}
