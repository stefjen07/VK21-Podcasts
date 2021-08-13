//
//  PodcastsView.swift
//  PodcastsView
//
//  Created by Евгений on 13.08.2021.
//

import SwiftUI
import Combine

struct PodcastItem: View {
    @Binding var podcast: Podcast
    
    var body: some View {
        NavigationLink(destination: PodcastView(podcast: $podcast)) {
            HStack {
                if let logo = podcast.logoCache {
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
                        Text(podcast.title)
                            .bold()
                            .lineLimit(1)
                        Spacer()
                    }
                    HStack {
                        Text(podcast.description)
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

struct SmartTint: ViewModifier {
    var color: Color
    
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content.tint(color)
        } else {
            content.accentColor(color)
        }
    }
}

extension View {
    func smartTint(_ color: Color) -> some View {
        return self.modifier(SmartTint(color: color))
    }
}

class ImageLoader: ObservableObject {
    @Binding var destination: Image?
    var data = Data() {
        didSet {
            if let uiImage = UIImage(data: data) {
                self.destination = Image(uiImage: uiImage)
            }
        }
    }

    init(urlString: String, destination: Binding<Image?>) {
        self._destination = destination
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

struct PodcastsView: View {
    @State var podcasts: [Podcast]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background")
                    .edgesIgnoringSafeArea(.all)
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: 15) {
                        ForEach($podcasts) { podcast in
                            PodcastItem(podcast: podcast)
                                .foregroundColor(.white)
                        }
                        Spacer()
                    }
                }
                .padding(.top, 10)
                .padding(.horizontal, 25)
            }
            .navigationTitle(
                Text("Подкасты")
            )
        }
        .smartTint(.white)
        .onAppear() {
            for podcast in $podcasts {
                if podcast.logoCache.wrappedValue == nil {
                    ImageLoader(urlString: podcast.wrappedValue.logoUrl, destination: podcast.logoCache)
                }
            }
        }
    }
    
    init() {
        let parser = RSSParser(url: URL(string: "https://vk.com/podcasts-147415323_-1000000.rss")!)
        parser.parse()
        self.podcasts = [parser.podcast]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
    }
}

struct PodcastsView_Previews: PreviewProvider {
    static var previews: some View {
        PodcastsView()
    }
}
