//
//  PodcastView.swift
//  PodcastView
//
//  Created by Евгений on 13.08.2021.
//

import SwiftUI

struct EpisodeItem: View {
    @Binding var episode: Episode
    let publishedFormatter = DateFormatter()
    
    func publishedDate(date: Date) -> String {
        publishedFormatter.dateFormat = "d MMMM, yyyy"
        publishedFormatter.locale = Locale(identifier: "ru_RU")
        return publishedFormatter.string(from: date)
    }
    
    var body: some View {
        VStack {
            HStack {
                if let logo = episode.logoCache {
                    logo
                        .resizable()
                        .aspectRatio(1, contentMode: .fill)
                        .cornerRadius(5)
                        .frame(width: 70)
                } else {
                    Color.gray.opacity(0.3)
                        .aspectRatio(1, contentMode: .fill)
                        .cornerRadius(5)
                        .frame(width: 70)
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
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                }
                .padding(.leading, 10)
                .frame(height: 70)
            }
            HStack {
                Text(episode.duration)
                Spacer()
                Text(publishedDate(date: episode.date))
            }
        }
    }
}

extension URL: Identifiable {
    public var id: Int {
        self.hashValue
    }
}

struct PodcastView: View {
    @Binding var podcast: Podcast
    @Binding var podcastsStorage: PodcastsStorage
    @Binding var userInfo: UserInfo
    @State var activityItem: URL?
    
    var body: some View {
        ZStack {
            Color("Background")
                .edgesIgnoringSafeArea(.all)
            if let logo = podcast.logoCache {
                GeometryReader { proxy in
                    let size = proxy.size
                    
                    VStack {
                        ZStack {
                            logo
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                            fadeGradient
                        }
                        .frame(width: size.width, height: size.width)
                        Spacer()
                    }.edgesIgnoringSafeArea(.all)
                }
            }
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    HStack {
                        Text(podcast.title)
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Spacer()
                    }
                        .padding(.bottom, 2)
                    HStack {
                        Text(podcast.description)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    ForEach(podcast.episodes.indices) { episodeIdx in
                        
                        if !podcast.episodes[episodeIdx].isExplicit || userInfo.ageMajority {
                            NavigationLink(destination: PlayerSwitcher(podcastsStorage: $podcastsStorage, podcast: $podcast, userInfo: $userInfo, episodeIdx: episodeIdx)) {
                                EpisodeItem(episode: $podcast.episodes[episodeIdx])
                            }
                            .padding(15)
                            .background(Color("VKColor"))
                            .cornerRadius(10)
                        }
                    }
                    PodcastInfo(podcast: podcast)
                    Button(action: {
                        if let data = try? JSONEncoder().encode(podcast.toJSON()) {
                            let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("podcast.json")
                            do {
                                try data.write(to: url)
                                activityItem = url
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }, label: {
                        Text("Выгрузить JSON файл с реакциями")
                            .foregroundColor(Color("VKColor"))
                    }).padding(.vertical, 15)
                }
                .padding(.top, 50)
                .padding(.horizontal, 25)
            }
        }
        .onAppear() {
            for episode in $podcast.episodes {
                if episode.logoCache.wrappedValue == nil {
                    ImageLoader(urlString: episode.wrappedValue.logoUrl, destination: episode.logoCache)
                }
            }
        }
        .sheet(item: $activityItem, onDismiss: {
            
        }, content: { item in
            ShareSheet(activityItems: [item])
        })
        .navigationTitle("")
    }
}

struct PodcastView_Previews: PreviewProvider {
    static var previews: some View {
        PodcastView(podcast: .constant(.init(title: "Подкаст", description: "Очень интересное описание подкаста", author: "stefjen07", logoUrl: "", reactions: [], episodes: [], email: "")), podcastsStorage: .constant(.init()), userInfo: .constant(.init()))
    }
}
