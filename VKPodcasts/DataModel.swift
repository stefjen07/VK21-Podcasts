//
//  DataModel.swift
//  DataModel
//
//  Created by Евгений on 11.08.2021.
//

import Foundation

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

struct Podcast {
    var reactions: [Reaction]
    var episodes: [Episode]
}

struct Model {
    var podcasts: [Podcast]
}
