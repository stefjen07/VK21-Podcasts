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
    
    var colsCount: Int {
        return Int((selfSize.width+colWidth/2)/(colWidth*1.5))
    }
    
    func colPercentage(idx: Int) -> CGFloat {
        return CGFloat(idx)/CGFloat(colsCount)
    }
    
    func isColActive(idx: Int) -> Bool {
        return true
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: colWidth/2) {
            ForEach(0..<colsCount) { i in
                Capsule()
                    .foregroundColor(isColActive(idx: i) ? Color("VKColor") : Color("VKColor").opacity(0.2))
                    .frame(width: colWidth, height: colPercentage(idx: i)*selfSize.height)
            }
        }
    }
}

struct ReactionsGraph_Previews: PreviewProvider {
    static var previews: some View {
        ReactionsGraph(selfSize: .init(width: 250, height: 80))
            .previewLayout(.fixed(width: 250, height: 80))
    }
}
