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

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}

func getCities(tIds: [Int], destination: Binding<[City]>) {
    var ids: [Int] = tIds.uniqued()
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
            if let response = response?.responseString {
                print("Cities received: \(response)")
                if let cities = try? JSONDecoder().decode(CitiesResponse.self, from: response.data(using: .utf8) ?? Data()) {
                    destination.wrappedValue.append(contentsOf: cities.response)
                }
            }
        }, errorBlock: { error in
            if let error = error {
                print(error.localizedDescription)
            }
        })
        ids.removeFirst(min(ids.count,1000))
    }
}

struct UserInfo {
    var firstName: String = ""
    var lastName: String = ""
    var sex: Sex = .female
    var age: Int = 0
    var ageMajority: Bool = false
    var cityId: Int = 0
}

struct Stat: Codable {
    var time: Int
    var reactionId: Int
    var sex: Sex
    var age: Int
    var cityId: Int
    
    init(time: Int, reactionId: Int, sex: Sex, age: Int, cityId: Int) {
        self.time = time
        self.reactionId = reactionId
        self.sex = sex
        self.age = age
        self.cityId = cityId
    }
    
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
    
    var valueAll = [Int]()
    var emojiValues = [[Int]]()
    var colPercentage = [CGFloat]()
    var lastColsCount: Int = 0
    var lastReactions: [Reaction] = []
    var updateDuration: Double = 0
    
    func idxForTime(time: Double, duration: Double, colsCount: Int) -> Int {
        if duration == 0 {
            return 0
        }
        return Int((time / duration) * Double(colsCount))
    }
    
    func recalculate() {
        calculateGraphsCache(reactions: lastReactions, duration: updateDuration, colsCount: lastColsCount)
    }
    
    func calculateGraphsCache(reactions: [Reaction], duration: Double, colsCount: Int) {
        self.valueAll = Array(repeating: 0, count: colsCount)
        self.emojiValues = Array(repeating: Array(repeating: 0, count: colsCount), count: reactions.count)
        
        for stat in statistics {
            var reactionIdx = 0
            for i in reactions.indices {
                if reactions[i].id == stat.reactionId {
                    reactionIdx = i
                    break
                }
            }
            let col = idxForTime(time: Double(stat.time)/1000, duration: duration, colsCount: colsCount)
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
        
        self.lastReactions = reactions
        self.lastColsCount = colsCount
        self.updateDuration = duration
    }
}

struct JSONEpisode: Codable {
    var guid: String
    var defaultReactions: [Int]
    var timedReactions: [TimedReactionsContainer]
    var statistics: [Stat]
    
    init(id: String, defaultReactions: [Int], timedReactions: [TimedReactionsContainer], statistics: [Stat]) {
        self.guid = id
        self.defaultReactions = defaultReactions
        self.timedReactions = timedReactions
        self.statistics = statistics
    }
    
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
    
    init(reactions: [Reaction], episodes: [JSONEpisode]) {
        self.reactions = reactions
        self.episodes = episodes
    }
}

class Podcast: ObservableObject, Identifiable {
    var id = UUID()
    var title: String
    var description: String
    var author: String
    var logoUrl: String
    var logoCache: Image?
    var email: String
    var category: String
    
    var reactions: [Reaction]
    var episodes: [Episode]
    
    func parseJSON(url: URL) {
        if let jsonData = try? Data(contentsOf: url) {
            parseJSON(data: jsonData)
        }
    }
    
    func toJSON() -> JSONPodcast {
        let podcast = JSONPodcast(reactions: reactions, episodes: episodes.map { JSONEpisode(id: $0.id, defaultReactions: $0.defaultReactions, timedReactions: $0.timedReactions, statistics: $0.statistics) })
        return podcast
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
    
    init(title: String, description: String, author: String, logoUrl: String, reactions: [Reaction], episodes: [Episode], email: String) {
        self.title = title
        self.description = description
        self.author = author
        self.logoUrl = logoUrl
        self.reactions = reactions
        self.episodes = episodes
        self.email = email
        self.category = ""
    }
    
    convenience init() {
        self.init(title: "", description: "", author: "", logoUrl: "", reactions: [], episodes: [], email: "")
    }
}

struct Model {
    var podcasts: [Podcast]
}
