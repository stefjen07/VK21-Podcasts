//
//  DataModel.swift
//  DataModel
//
//  Created by Евгений on 11.08.2021.
//

import SwiftUI
import VK_ios_sdk

struct Reaction: Codable, Identifiable {
    var statSelectionIdx: Int?
    var id: Int
    var emoji: String
    var description: String
    var isAvailable: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case reaction_id
        case emoji
        case description
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .reaction_id)
        try container.encode(emoji, forKey: .emoji)
        try container.encode(description, forKey: .description)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let reactionId = try? container.decode(Int.self, forKey: .reaction_id) {
            self.id = reactionId
        } else {
            self.id = -1
        }
        if let emoji = try? container.decode(String.self, forKey: .emoji) {
            self.emoji = emoji
        } else {
            self.emoji = ""
        }
        if let description = try? container.decode(String.self, forKey: .description) {
            self.description = description
        } else {
            self.description = ""
        }
    }
}

struct TimedReactionsContainer: Codable {
    var from: Int
    var to: Int
    var availableReactions: [Int]
    
    enum CodingKeys: String, CodingKey {
        case from
        case to
        case available_reactions
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(String(from), forKey: .from)
        try container.encode(String(to), forKey: .to)
        try container.encode(availableReactions, forKey: .available_reactions)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let from = try? container.decode(String.self, forKey: .from) {
            self.from = Int(from) ?? -1
        } else {
            self.from = -1
        }
        if let to = try? container.decode(String.self, forKey: .to) {
            self.to = Int(to) ?? -1
        } else {
            self.to = -1
        }
        if let availableReactions = try? container.decode([Int].self, forKey: .available_reactions) {
            self.availableReactions = availableReactions
        } else {
            self.availableReactions = []
        }
    }
}

enum Sex: String, Codable {
    case male
    case female
}

struct City: Codable {
    var id: Int
    var title: String
}

struct CitiesResponse: Codable {
    var response: [City]
}

func localeForRequest() -> String {
    return Locale.current.languageCode ?? Locale.current.identifier
}

func getCities(tIds: [Int], destination: Binding<[City]>) {
    var ids: [Int] = tIds
    destination.wrappedValue = []
    while ids.count != 0 {
        var reqIds = [Int]()
        for i in 0..<min(ids.count, 1000) {
            reqIds.append(ids[i])
        }
        let request = VKRequest(method: "database.getCitiesById", parameters: [
            "city_ids": reqIds,
            "access_token": VKSdk.accessToken().accessToken ?? "",
            "lang": localeForRequest()
        ])
        request?.execute(resultBlock: { response in
            print("Cities received: \(response?.responseString)")
            if let cities = try? JSONDecoder().decode(CitiesResponse.self, from: response!.responseString.data(using: .utf8) ?? Data()) {
                destination.wrappedValue.append(contentsOf: cities.response)
            }
        }, errorBlock: { error in
            print(error?.localizedDescription)
        })
        ids.removeFirst(min(ids.count,1000))
    }
}

struct Stat: Codable {
    var time: Int
    var reactionId: Int
    var sex: Sex
    var age: Int
    var cityId: Int
    
    enum CodingKeys: String, CodingKey {
        case time
        case reaction_id
        case sex
        case age
        case city_id
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(time, forKey: .time)
        try container.encode(reactionId, forKey: .reaction_id)
        try container.encode(sex, forKey: .sex)
        try container.encode(age, forKey: .age)
        try container.encode(cityId, forKey: .city_id)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let time = try? container.decode(Int.self, forKey: .time) {
            self.time = time
        } else {
            self.time = -1
        }
        if let reactionId = try? container.decode(Int.self, forKey: .reaction_id) {
            self.reactionId = reactionId
        } else {
            self.reactionId = -1
        }
        if let sex = try? container.decode(Sex.self, forKey: .sex) {
            self.sex = sex
        } else {
            self.sex = .female
        }
        if let age = try? container.decode(Int.self, forKey: .age) {
            self.age = age
        } else {
            self.age = -1
        }
        if let cityId = try? container.decode(Int.self, forKey: .city_id) {
            self.cityId = cityId
        } else {
            self.cityId = -1
        }
    }
}

class Episode: ObservableObject, Identifiable {
    var id: String = ""
    var title: String = ""
    var description: String = ""
    var logoUrl: String = ""
    var audioUrl: String = ""
    var logoCache: Image?
    var defaultReactions: [Int] = []
    var timedReactions: [TimedReactionsContainer] = []
    var statistics: [Stat] = []
    var isExplicit: Bool = false
    var date: Date = .init()
    var duration: String = ""
}

struct JSONEpisode: Codable {
    var guid: String
    var defaultReactions: [Int]
    var timedReactions: [TimedReactionsContainer]
    var statistics: [Stat]
    
    enum CodingKeys: String, CodingKey {
        case guid
        case default_reactions
        case timed_reactions
        case statistics
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(guid, forKey: .guid)
        try container.encode(defaultReactions, forKey: .default_reactions)
        try container.encode(timedReactions, forKey: .timed_reactions)
        try container.encode(statistics, forKey: .statistics)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let guid = try? container.decode(String.self, forKey: .guid) {
            self.guid = guid
        } else {
            self.guid = ""
        }
        if let defaultReactions = try? container.decode([Int].self, forKey: .default_reactions) {
            self.defaultReactions = defaultReactions
        } else {
            self.defaultReactions = []
        }
        if let timedReactions = try? container.decode([TimedReactionsContainer].self, forKey: .timed_reactions) {
            self.timedReactions = timedReactions
        } else {
            self.timedReactions = []
        }
        if let statistics = try? container.decode([Stat].self, forKey: .statistics) {
            self.statistics = statistics
        } else {
            self.statistics = []
        }
    }
}

struct JSONPodcast: Codable {
    var reactions: [Reaction]
    var episodes: [JSONEpisode]
    
    enum CodingKeys: String, CodingKey {
        case reactions
        case episodes
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(reactions, forKey: .reactions)
        try container.encode(episodes, forKey: .episodes)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let reactions = try? container.decode([Reaction].self, forKey: .reactions) {
            self.reactions = reactions
        } else {
            self.reactions = []
        }
        if let episodes = try? container.decode([JSONEpisode].self, forKey: .episodes) {
            self.episodes = episodes
        } else {
            self.episodes = []
        }
    }
}

class Podcast: ObservableObject, Identifiable {
    var id = UUID()
    var title: String
    var description: String
    var author: String
    var logoUrl: String
    var logoCache: Image?
    var reactions: [Reaction]
    
    var episodes: [Episode]
    
    func parseJSON(name: String) {
        if let bundlePath = Bundle.main.path(forResource: name,
                                                     ofType: "json"),
            let jsonData = try? String(contentsOfFile: bundlePath).data(using: .utf8) {
            parseJSON(data: jsonData)
        }
    }
    
    func parseJSON(data: Data) {
        do {
            let json = try JSONDecoder().decode(JSONPodcast.self, from: data)
            self.reactions = json.reactions
            for episode in episodes {
                for i in json.episodes {
                    if i.guid == episode.id {
                        episode.statistics = i.statistics
                        episode.timedReactions = i.timedReactions
                        episode.defaultReactions = i.defaultReactions
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
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
