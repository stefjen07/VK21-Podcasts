//
//  PodcastsStorage.swift
//  PodcastsStorage
//
//  Created by Евгений on 17.08.2021.
//

import SwiftUI

struct StoragePodcastConfig: Codable {
    var rssUrl: URL?
    var rssData: Data
    var jsonData: Data
    
    mutating func load() {
        if let rssUrl = rssUrl {
            rssData = (try? Data(contentsOf: rssUrl)) ?? rssData
        }
    }
}

struct UserStat: Codable {
    var stat: Stat
    var date: Date
}

struct StatSeconds: Codable {
    var id: String
    var seconds: Double
}

struct UserStatStorage: Codable {
    var userStats: [UserStat]
    var lastSeconds: [StatSeconds]
    
    mutating func setSeconds(id: String, seconds: Double) {
        for i in lastSeconds.indices {
            if lastSeconds[i].id == id {
                lastSeconds[i].seconds = seconds
            }
        }
        lastSeconds.append(.init(id: id, seconds: seconds))
        save()
    }
    
    func seconds(_ id: String) -> Double {
        for lastSecond in lastSeconds {
            if lastSecond.id == id {
                return lastSecond.seconds
            }
        }
        return 0
    }
    
    var url: URL {
        let fm = FileManager.default
        if let url = fm.urls(for: .documentDirectory, in: .userDomainMask).first {
            return url.appendingPathComponent("stats.storage")
        }
        return URL(fileURLWithPath: "")
    }
    
    init() {
        self.userStats = []
        self.lastSeconds = []
        guard let data = try? Data(contentsOf: url) else {
            return
        }
        
        if let userStatStorage = try? JSONDecoder().decode(UserStatStorage.self, from: data) {
            self.userStats = userStatStorage.userStats
            self.lastSeconds = userStatStorage.lastSeconds
        }
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            try? data.write(to: url)
        }
    }
    
    mutating func addStat(_ stat: UserStat) {
        userStats.append(stat)
        save()
    }
    
    func countForInterval(_ interval: TimeInterval) -> Int {
        var result = 0
        for stat in userStats {
            if Date().timeIntervalSince(stat.date) <= interval {
                result += 1
            }
        }
        return result
    }
}

var statStorage = UserStatStorage()

struct PodcastsStorage {
    var podcasts: [Podcast]
    var configs: [StoragePodcastConfig]
    
    var url: URL {
        let fm = FileManager.default
        if let url = fm.urls(for: .documentDirectory, in: .userDomainMask).first {
            return url.appendingPathComponent("podcasts.storage")
        }
        return URL(fileURLWithPath: "")
    }
    
    init() {
        self.podcasts = []
        self.configs = []
        guard let data = try? Data(contentsOf: url) else {
            return
        }
        
        if let configs = try? JSONDecoder().decode([StoragePodcastConfig].self, from: data) {
            self.configs = configs
            reloadPodcastsFromConfigs()
        }
    }
    
    func podcastsToConfigs() -> [StoragePodcastConfig] {
        var result = configs
        for i in result.indices {
            let json = podcasts[i].toJSON()
            if let data = try? JSONEncoder().encode(json) {
                result[i].jsonData = data
            }
        }
        return result
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(podcastsToConfigs()) {
            try? data.write(to: url)
        }
    }
    
    mutating func reloadPodcastsFromConfigs() {
        var podcasts = [Podcast]()
        for i in configs.indices {
            configs[i].load()
            let parser = RSSParser(data: configs[i].rssData)
            parser.parse()
            parser.podcast.parseJSON(data: configs[i].jsonData)
            podcasts.append(parser.podcast)
        }
        self.podcasts = podcasts
    }
    
    mutating func addPodcast(config: StoragePodcastConfig) {
        configs.append(config)
        reloadPodcastsFromConfigs()
        save()
    }
}
