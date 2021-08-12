//
//  RSSParser.swift
//  RSSParser
//
//  Created by Евгений on 12.08.2021.
//

import SwiftUI
import Combine

class ImageLoader: ObservableObject {
    var didChange = PassthroughSubject<Data, Never>()
    var data = Data() {
        didSet {
            didChange.send(data)
        }
    }

    init(urlString:String) {
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.data = data
            }
        }
        task.resume()
    }
}

class RSSParser: NSObject, XMLParserDelegate {
    var parser: XMLParser
    var tempPodcast: Podcast?
    var tempElement: String?
    var podcasts: [Podcast] = []
    var isInItem = false
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("Parse error: \(parseError.localizedDescription)")
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        tempElement = elementName
        if elementName == "item" {
            isInItem = true
            tempPodcast = Podcast()
        } else if elementName == "itunes:image" {
            if isInItem {
                tempPodcast?.logoUrl = attributeDict["href"] ?? ""
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            if let podcast = tempPodcast {
                podcasts.append(podcast)
            }
            tempPodcast = nil
            isInItem = false
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if let podcast = tempPodcast {
            if tempElement == "title" {
                tempPodcast?.title = podcast.title + string
            }
        }
    }
    
    func parse() {
        podcasts = []
        parser.delegate = self
        parser.parse()
    }
    
    init(url: URL) {
        parser = XMLParser(contentsOf: url) ?? XMLParser()
    }
}
