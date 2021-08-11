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
            .overlay(
                Text(emoji)
            )
    }
}

struct ReactionItem_Previews: PreviewProvider {
    static var previews: some View {
        ReactionItem(emoji: "👍")
            .previewLayout(.fixed(width: 60, height: 60))
    }
}
