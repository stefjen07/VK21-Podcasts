//
//  ReactionItem.swift
//  ReactionItem
//
//  Created by Евгений on 11.08.2021.
//

import SwiftUI

struct ReactionItem: View {
    var emoji: String
    var body: some View {
        Circle()
            .foregroundColor(.init("Background").opacity(0.3))
            .frame(width: 80, height: 80)
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
        ReactionItem(emoji: "👍")
            .previewLayout(.fixed(width: 60, height: 60))
    }
}
