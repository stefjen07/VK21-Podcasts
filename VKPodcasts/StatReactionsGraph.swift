//
//  StatReactionsGraph.swift
//  StatReactionsGraph
//
//  Created by Евгений on 16.08.2021.
//

import SwiftUI

func getBottomDegrees(maxValue: Double, count: Int, leadingZero: Bool) -> [String] {
    var degrees = [String]()
    var currentDegree: Double = 0
    var lastDegree = ""
    let scale: Double = maxValue / Double(count - 1)
    while(currentDegree <= maxValue) {
        let newDegree = "\(Int(currentDegree)>9 || !leadingZero ? "" : "0")\(Int(currentDegree))"
        if lastDegree != newDegree {
            lastDegree = newDegree
            degrees.append(newDegree)
        }
        currentDegree += scale
    }
    return degrees
}

struct StatReactionsGraph: View {
    var height: CGFloat
    let duration: Double
    let colsCount: Int
    let degrees: [String]
    @State var leftBound: Int
    @State var rightBound: Int
    @Binding var difference: String
    
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
    
    func isActive(idx: Int) -> Bool {
        return idx >= leftBound && idx <= rightBound
    }
    
    var colPercentage: [CGFloat]
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            HStack(alignment: .bottom, spacing: 3) {
                ForEach(0..<colsCount) { i in
                    Capsule()
                        .foregroundColor(isActive(idx: i) ? Color("VKColor") : Color("VKColor").opacity(0.2))
                        .frame(height: max(5, colPercentage[i]*(height-20)))
                }
            }
            HStack {
                ForEach(degrees.indices) { i in
                    if i != 0 {
                        Spacer()
                    }
                    Text(degrees[i])
                        .font(.subheadline)
                        .foregroundColor(.init(white: 0.65))
                }.frame(height: 10)
            }
        }.frame(height: height)
    }
    
    init(height: CGFloat, duration: Double, episode: Episode, difference: Binding<String>) {
        self.height = height
        self.duration = duration
        self._difference = difference
        self.colsCount = min(max(1, Int((duration + 30) / 60)), 60)
        self.leftBound = 0
        self.rightBound = colsCount - 1
        self.degrees = getBottomDegrees(maxValue: (duration + 30) / 60, count: 9, leadingZero: true)
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

struct StatReactionsGraph_Previews: PreviewProvider {
    static var previews: some View {
        StatReactionsGraph(height: 150, duration: 30, episode: Episode(), difference: .constant(""))
    }
}
