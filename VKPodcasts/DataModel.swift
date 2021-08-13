//
//  DataModel.swift
//  DataModel
//
//  Created by Евгений on 11.08.2021.
//

import SwiftUI

struct Reaction {
    var id: Int
    var emoji: String
    var description: String
}

struct TimedReactionsContainer {
    var from: Int
    var to: Int
    var availableReactions: [Int]
}

enum Sex {
    case male
    case female
}

struct Stat {
    var time: Int
    var reactionId: Int
    var sex: Sex
    var age: Int
    var cityId: Int
}

struct Episode {
    var id: String
    var defaultReactions: [Int]
    var timedReactions: [TimedReactionsContainer]
    var statistics: [Stat]
}

class Podcast: ObservableObject, Identifiable {
    var title: String
    var description: String
    var author: String
    var logoUrl: String
    var logoCache: Image?
    var reactions: [Reaction]
    var episodes: [Episode]
    
    init(title: String, description: String, author: String, logoUrl: String, reactions: [Reaction], episodes: [Episode]) {
        self.title = title
        self.description = description
        self.author = author
        self.logoUrl = logoUrl
        self.reactions = reactions
        self.episodes = episodes
    }
    
    convenience init() {
        self.init(title: "", description: "", author: "", logoUrl: "", reactions: [], episodes: [])
    }
}

struct Model {
    var podcasts: [Podcast]
}
