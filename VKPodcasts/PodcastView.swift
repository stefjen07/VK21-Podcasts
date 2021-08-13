//
//  PodcastView.swift
//  PodcastView
//
//  Created by Евгений on 13.08.2021.
//

import SwiftUI

struct PodcastView: View {
    @Binding var podcast: Podcast
    
    var body: some View {
        ZStack {
            Color("Background")
                .edgesIgnoringSafeArea(.all)
            VStack {
                ForEach(podcast.episodes) { episode in
                    NavigationLink(destination: PlayerView(episode: episode, author: $podcast.author)) {
                        HStack {
                            if let logo = episode.logoCache {
                                logo
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .cornerRadius(5)
                                    .frame(width: 50)
                            } else {
                                Color.gray.opacity(0.3)
                                    .aspectRatio(1, contentMode: .fill)
                                    .cornerRadius(5)
                                    .frame(width: 50)
                            }
                            VStack {
                                HStack {
                                    Text(episode.title)
                                        .bold()
                                        .lineLimit(1)
                                    Spacer()
                                }
                                HStack {
                                    Text(episode.description)
                                        .foregroundColor(.init(white: 0.9))
                                        .lineLimit(2)
                                    Spacer()
                                }
                            }.padding(.leading, 10)
                            Spacer()
                        }
                    }
                    .padding(15)
                    .background(Color("VKColor"))
                    .cornerRadius(10)
                }
            }
        }.onAppear() {
            for episode in $podcast.episodes {
                if episode.logoCache.wrappedValue == nil {
                    ImageLoader(urlString: episode.wrappedValue.logoUrl, destination: episode.logoCache)
                }
            }
        }
    }
}

struct PodcastView_Previews: PreviewProvider {
    static var previews: some View {
        PodcastView(podcast: .constant(.init()))
    }
}
