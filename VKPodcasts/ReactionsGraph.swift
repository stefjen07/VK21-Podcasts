//
//  ReactionsGraph.swift
//  ReactionsGraph
//
//  Created by Евгений on 12.08.2021.
//

import SwiftUI

struct EmojiGraph: View {
    var selfSize: CGSize
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            
            HStack {
                
            }
        }
    }
}

struct ReactionsGraph: View {
    var selfSize: CGSize
    let colWidth: CGFloat = 4
    let duration: Double
    let currentTime: Double
    
    var colsCount: Int {
        return Int((selfSize.width+colWidth/2)/(colWidth*1.5))
    }
    
    func intervalForCol(idx: Int) -> Range<Double> {
        if colsCount == 0 {
            return 0..<0
        }
        return (duration * Double(idx) / Double(colsCount))..<(duration * Double(idx+1) / Double(colsCount))
    }
    
    func idxForTime(time: Double) -> Int {
        if duration == 0 {
            return 0
        }
        return Int((time / duration) * Double(colsCount))
    }
    
    var colPercentage: [CGFloat]
    
    func isColActive(idx: Int) -> Bool {
        return currentTime >= intervalForCol(idx: idx).lowerBound
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: colWidth/2) {
            ForEach(0..<colsCount) { i in
                Capsule()
                    .foregroundColor(isColActive(idx: i) ? Color("VKColor") : Color("VKColor").opacity(0.2))
                    .frame(width: colWidth, height: colPercentage[i]*selfSize.height)
            }
        }
    }
    
    init(selfSize: CGSize, duration: Double, currentTime: Double, episode: Episode) {
        self.selfSize = selfSize
        self.duration = duration
        self.currentTime = currentTime
        self.colPercentage = []
        self.colPercentage = Array(repeating:.zero, count: colsCount)
        
        for stat in episode.statistics {
            colPercentage[idxForTime(time: Double(stat.time)/1000)] += 1
        }
        
        var maxValue: CGFloat = 0
        
        for colPercentage in colPercentage {
            maxValue = max(maxValue, colPercentage)
        }
        if maxValue != 0 {
            for i in 0..<colPercentage.count {
                colPercentage[i] /= maxValue
            }
        }
    }
}

struct ReactionsGraph_Previews: PreviewProvider {
    static var previews: some View {
        ReactionsGraph(selfSize: .init(width: 250, height: 80), duration: 0, currentTime: 0, episode: Episode())
            .previewLayout(.fixed(width: 250, height: 80))
    }
}
