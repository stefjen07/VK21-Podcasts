//
//  ReactionItem.swift
//  ReactionItem
//
//  Created by Евгений on 11.08.2021.
//

import SwiftUI

struct ReactionItem: View {
    var width: CGFloat
    var emoji: String
    var body: some View {
        Circle()
            .foregroundColor(.init("Background").opacity(0.3))
            .frame(width: width, height: width)
            .overlay(
                ZStack {
                    Circle()
                        .stroke(.gray, lineWidth: 1)
                    Text(emoji)
                        .font(.title)
                }
            )
    }
}

struct ReactionItem_Previews: PreviewProvider {
    static var previews: some View {
        ReactionItem(width: 80, emoji: "👍")
    }
}
