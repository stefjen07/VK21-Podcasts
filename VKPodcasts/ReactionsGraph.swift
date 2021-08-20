//
//  ReactionsGraph.swift
//  ReactionsGraph
//
//  Created by Евгений on 12.08.2021.
//

import SwiftUI

struct ReactionsGraph: View {
    @Binding var episode: Episode
    @Binding var currentTime: Double
    var duration: Double
    var reactions: [Reaction]
    var selfSize: CGSize
    let colWidth: CGFloat = 4
    
    var colsCount: Int {
        return Int((selfSize.width+colWidth/2)/(colWidth*1.5))
    }
    
    func intervalForCol(idx: Int) -> Range<Double> {
        if colsCount == 0 {
            return 0..<0
        }
        return (duration * Double(idx) / Double(colsCount))..<(duration * Double(idx+1) / Double(colsCount))
    }
    
    func isColActive(idx: Int) -> Bool {
        return currentTime >= intervalForCol(idx: idx).lowerBound
    }
    
    var body: some View {
        ZStack {
            HStack(alignment: .bottom, spacing: colWidth / 2.0) {
                ForEach(0..<colsCount) { i in
                    VStack(spacing: 0) {
                        Spacer(minLength: 0)
                        Capsule()
                            .foregroundColor(isColActive(idx: i) ? Color("VKColor") : Color("VKColor").opacity(0.2))
                            .frame(width: colWidth, height: max(colWidth, episode.colPercentage[i]*(selfSize.height-20)))
                    }
                }
            }.padding(.top, 30)
            EmojiGraph(values: episode.emojiValues, valueAll: episode.valueAll, reactions: reactions)
        }.frame(height: selfSize.height)
    }
    
    init(selfSize: CGSize, duration: Double, currentTime: Binding<Double>, episode: Binding<Episode>, reactions: [Reaction]) {
        self.selfSize = selfSize
        self.duration = duration
        self._currentTime = currentTime
        self.reactions = reactions
        self._episode = episode
        if self.episode.colPercentage.count != colsCount || duration != self.episode.updateDuration {
            print("Graph updated")
            self.episode.calculateGraphsCache(reactions: reactions, duration: duration, colsCount: colsCount)
        }
    }
}

struct ReactionsGraph_Previews: PreviewProvider {
    static var previews: some View {
        ReactionsGraph(selfSize: .init(width: 250, height: 80), duration: 0, currentTime: .constant(0), episode: .constant(.init()), reactions: [])
            .previewLayout(.fixed(width: 250, height: 80))
    }
}
