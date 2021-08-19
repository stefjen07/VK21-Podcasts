//
//  ReactionsGraph.swift
//  ReactionsGraph
//
//  Created by Евгений on 12.08.2021.
//

import SwiftUI

struct ReactionsGraph: View {
    @Binding var episode: Episode
    var reactions: [Reaction]
    var selfSize: CGSize
    let colWidth: CGFloat = 4
    let duration: Double
    let currentTime: Double
    var emojiValues: [[Int]]
    var valueAll: [Int]
    
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
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                    .frame(height: 30)
                HStack(spacing: 0) {
                    HStack(alignment: .bottom, spacing: colWidth / 2.0) {
                        ForEach(0..<colsCount) { i in
                            VStack(spacing: 0) {
                                Spacer(minLength: 0)
                                Capsule()
                                    .foregroundColor(isColActive(idx: i) ? Color("VKColor") : Color("VKColor").opacity(0.2))
                                    .frame(width: colWidth, height: max(colWidth, colPercentage[i]*(selfSize.height-20)))
                            }
                        }
                    }
                    Spacer(minLength: 0)
                }
            }.frame(width: selfSize.width)
            EmojiGraph(values: emojiValues, valueAll: valueAll, reactions: reactions)
        }.frame(height: selfSize.height)
    }
    
    init(selfSize: CGSize, duration: Double, currentTime: Double, episode: Binding<Episode>, reactions: [Reaction]) {
        self.selfSize = selfSize
        self.duration = duration
        self.currentTime = currentTime
        self.reactions = reactions
        self._episode = episode
        self.emojiValues = []
        self.colPercentage = []
        self.valueAll = []
        self.valueAll = Array(repeating: 0, count: colsCount)
        self.emojiValues = Array(repeating: Array(repeating: 0, count: colsCount), count: reactions.count)
        
        for stat in self.episode.statistics {
            var reactionIdx = 0
            for i in reactions.indices {
                if reactions[i].id == stat.reactionId {
                    reactionIdx = i
                    break
                }
            }
            let col = idxForTime(time: Double(stat.time)/1000)
            emojiValues[reactionIdx][col] += 1
            valueAll[col] += 1
        }
        
        colPercentage = valueAll.map { CGFloat($0) }
        
        let maxValue = colPercentage.reduce(0, max)
        
        if maxValue != 0 {
            for i in 0..<colPercentage.count {
                colPercentage[i] /= maxValue
            }
        }
    }
}

struct ReactionsGraph_Previews: PreviewProvider {
    static var previews: some View {
        ReactionsGraph(selfSize: .init(width: 250, height: 80), duration: 0, currentTime: 0, episode: .constant(.init()), reactions: [])
            .previewLayout(.fixed(width: 250, height: 80))
    }
}
