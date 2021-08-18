//
//  EmojiGraph.swift
//  EmojiGraph
//
//  Created by Евгений on 18.08.2021.
//

import SwiftUI

struct EmojiGraphData: Identifiable {
    var id = UUID()
    var emoji: String
    var start: Int
    var end: Int
}

struct SumSubrange {
    var positive: Bool
    var left: Int
    var right: Int
}

func getBestSubrange(values: [Int], data: [EmojiGraphData]) -> SumSubrange {
    var firstSum = 0
    for i in 0..<min(3, values.count) {
        firstSum += values[i]
    }
    var ans = SumSubrange(positive: firstSum > 0, left: 0, right: min(2, values.count-1))
    var maxSum = firstSum
    var sum = maxSum, minSum = maxSum, minSumIdx = 0
    if values.count > 1 {
        for r in 1..<values.count {
            sum += values[r]
            if sum - minSum > maxSum && r - minSumIdx > 1 {
                var overlapping = false
                for item in data {
                    if (minSumIdx...r).overlaps((item.start...item.end)) {
                        overlapping = true
                        break
                    }
                }
                if !overlapping {
                    maxSum = sum - minSum
                    ans = .init(positive: maxSum > 0, left: minSumIdx, right: r)
                }
            }
            if sum < minSum {
                minSum = sum
                minSumIdx = r
            }
        }
    }
    return ans
}

struct EmojiGraph: View {
    var data: [EmojiGraphData]
    
    var body: some View {
        ZStack {
            ForEach(data) { item in
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(item.emoji)
                            .font(.caption)
                            .frame(width: CGFloat(6 * (item.end - item.start + 1) - 2), height: 15)
                        LinearGradient(colors: [.init(white: 0.8).opacity(0.4), .clear], startPoint: .top, endPoint: .bottom)
                            .cornerRadius(4, corners: [.topLeft, .topRight])
                            .frame(width: CGFloat(6 * (item.end - item.start + 1) - 2))
                    }
                        .offset(x: CGFloat(item.start * 6))
                    Spacer()
                }
            }
        }
    }
    
    init(values: [[Int]], reactions: [Reaction]) {
        self.data = []
        let colsCount = (values.first?.count ?? 1)
        var valueAll = Array(repeating: 0, count: colsCount)
        for i in 0..<values.count {
            for j in 0..<colsCount {
                valueAll[j] += values[i][j]
            }
        }
        for i in reactions.indices {
            let reactionValues = (0..<colsCount).indices.map { values[i][$0]*2 - valueAll[$0] }
            let bestRange = getBestSubrange(values: reactionValues, data: data)
            if bestRange.positive {
                data.append(.init(emoji: reactions[i].emoji, start: bestRange.left, end: bestRange.right))
            }
        }
        print(data)
    }
}
