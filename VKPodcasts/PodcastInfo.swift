//
//  PodcastInfo.swift
//  PodcastInfo
//
//  Created by Евгений on 17.08.2021.
//

import SwiftUI

struct InfoRow: View {
    @Environment(\.colorScheme) var colorScheme
    var title: LocalizedStringKey
    var value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(colorScheme == .dark ? .init(white: 0.65) : .init(white: 0.35))
            Spacer()
            Text(value)
                .foregroundColor(.primary)
        }
    }
}

struct PodcastInfo: View {
    @Environment(\.colorScheme) var colorScheme
    var podcast: Podcast
    
    var body: some View {
        VStack(spacing: 10) {
            Text("additional-info")
                .font(.headline)
            InfoRow(title: "podcast-сategory", value: podcast.category)
            InfoRow(title: "contains-explicit", value: String(format: NSLocalizedString(podcast.episodes.contains(where: { episode in
                return episode.isExplicit
            }) ? "yes" : "no", comment: "")))
            InfoRow(title: "author", value: podcast.author)
            InfoRow(title: "author-email", value: podcast.email)
        }
        .padding(20)
        .background(colorScheme == .light ? Color.white.brightness(0).opacity(0.7) : Color("Background").brightness(0.4).opacity(0.7))
        .cornerRadius(10)
        .padding(.top, 15)
    }
}

struct PodcastInfo_Previews: PreviewProvider {
    static var previews: some View {
        PodcastInfo(podcast: .init())
    }
}
