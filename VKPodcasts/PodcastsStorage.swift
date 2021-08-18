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

struct UserStatStorage {
    var userStats: [UserStat]
    
    var url: URL {
        let fm = FileManager.default
        if let url = fm.urls(for: .documentDirectory, in: .userDomainMask).first {
            return url.appendingPathComponent("stats.storage")
        }
        return URL(fileURLWithPath: "")
    }
    
    init() {
        self.userStats = []
        guard let data = try? Data(contentsOf: url) else {
            return
        }
        
        if let userStats = try? JSONDecoder().decode([UserStat].self, from: data) {
            self.userStats = userStats
        }
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(userStats) {
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
