//
//  PodcastView.swift
//  PodcastView
//
//  Created by Евгений on 13.08.2021.
//

import SwiftUI

struct PodcastView: View {
    @Binding var podcast: Podcast
    @Environment(\.presentationMode) var presentation: Binding<PresentationMode>
    
    let publishedFormatter = DateFormatter()
    
    func publishedDate(date: Date) -> String {
        publishedFormatter.dateFormat = "d MMMM, yyyy"
        publishedFormatter.locale = Locale(identifier: "ru_RU")
        return publishedFormatter.string(from: date)
    }
    
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
                    ForEach(podcast.episodes) { episode in
                        NavigationLink(destination: PlayerView(episode: episode, author: $podcast.author)) {
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
                        .padding(15)
                        .background(Color("VKColor"))
                        .cornerRadius(10)
                    }
                }
                .padding(.top, 40)
                .padding(.horizontal, 25)
            }
            VStack {
                HStack {
                    Button(action: {
                        presentation.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "chevron.backward")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(5)
                            .frame(height: 30)
                    })
                    Spacer()
                }
                .foregroundColor(.white)
                .padding(.horizontal, 15)
                .padding(.top, 5)
                Spacer()
            }
        }
        .onAppear() {
            for episode in $podcast.episodes {
                if episode.logoCache.wrappedValue == nil {
                    ImageLoader(urlString: episode.wrappedValue.logoUrl, destination: episode.logoCache)
                }
            }
        }
        .navigationBarHidden(true)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(coordinateSpace: .local)
                .onEnded { value in
                    if value.translation.width > .zero
                        && value.translation.height > -30
                        && value.translation.height < 30 {
                        presentation.wrappedValue.dismiss()
                    }
                }
        )
    }
}

struct PodcastView_Previews: PreviewProvider {
    static var previews: some View {
        PodcastView(podcast: .constant(.init(title: "Подкаст", description: "Очень интересное описание подкаста", author: "stefjen07", logoUrl: "", reactions: [], episodes: [])))
    }
}
