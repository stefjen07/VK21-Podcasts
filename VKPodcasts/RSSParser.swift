//
//  RSSParser.swift
//  RSSParser
//
//  Created by Евгений on 12.08.2021.
//

import SwiftUI

class RSSParser: NSObject, XMLParserDelegate {
    var parser: XMLParser
    var tempEpisode: Episode?
    var tempElement: String?
    var tempExplicit: String?
    var tempDate: String?
    var podcast = Podcast()
    var isInItem = false
    var isInImage = false
    var isInImageURL = false
    var isInItemDescription = false
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("Parse error: \(parseError.localizedDescription)")
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        tempElement = elementName
        if elementName == "item" {
            isInItem = true
            tempEpisode = Episode()
            tempExplicit = ""
            tempDate = ""
        } else if elementName == "itunes:image" && isInItem {
            tempEpisode?.logoUrl = attributeDict["href"] ?? ""
        } else if elementName == "image" && !isInItem {
            isInImage = true
        } else if elementName == "url" && isInImage {
            isInImageURL = true
        } else if elementName == "content:encoded" && isInItem {
            isInItemDescription = true
        } else if elementName == "enclosure" && isInItem {
            tempEpisode?.audioUrl = attributeDict["url"] ?? ""
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            if let episode = tempEpisode {
                if let explicit = tempExplicit {
                    episode.isExplicit = explicit != "no"
                }
                if let date = tempDate {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
                    episode.date = formatter.date(from: date) ?? Date()
                }
                podcast.episodes.append(episode)
            }
            tempEpisode = nil
            tempExplicit = nil
            tempDate = nil
            isInItem = false
        }  else if elementName == "image" && !isInItem {
            isInImage = false
        } else if elementName == "url" && isInImage {
            isInImageURL = false
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if let episode = tempEpisode, let explicit = tempExplicit, let date = tempDate {
            if tempElement == "title" {
                tempEpisode?.title = episode.title + string
            } else if tempElement == "guid" {
                tempEpisode?.id = episode.id + string
            } else if tempElement == "itunes:expilict" {
                tempExplicit? = explicit + string
            } else if tempElement == "pubDate" {
                tempDate? = date + string
            } else if tempElement == "itunes:duration" {
                tempEpisode?.duration = episode.duration + string
            }
        } else {
            if tempElement == "title" && !isInImage {
                podcast.title += string
            } else if tempElement == "itunes:author" {
                podcast.author += string
            } else if isInImageURL {
                podcast.logoUrl += string
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        if !isInItem && tempElement == "description" {
            podcast.description = String(data: CDATABlock, encoding: .utf8) ?? ""
        } else if isInItemDescription {
            tempEpisode?.description = String(data: CDATABlock, encoding: .utf8) ?? ""
        }
    }
    
    func parse() {
        podcast = .init()
        parser.delegate = self
        parser.parse()
        podcast.logoUrl = podcast.logoUrl.removingPercentEncoding ?? podcast.logoUrl
    }
    
    init(url: URL) {
        parser = XMLParser(contentsOf: url) ?? XMLParser()
    }
}
