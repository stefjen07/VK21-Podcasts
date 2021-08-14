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

struct NewPodcastView: View {
    @State var url: String = ""
    @Binding var podcasts: [Podcast]
    @Environment(\.presentationMode) var presentation: Binding<PresentationMode>
    
    var body: some View {
        ZStack {
            Color("Background")
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 15) {
                HStack {
                    Button(action: {
                        presentation.wrappedValue.dismiss()
                    }, label: {
                        Text("Отменить")
                    })
                    Spacer()
                    Button(action: {
                        if let url = URL(string: url) {
                            let parser = RSSParser(url: url)
                            parser.parse()
                            podcasts.append(parser.podcast)
                            presentation.wrappedValue.dismiss()
                        }
                    }, label: {
                        Text("Готово")
                    })
                }
                Text("Новый подкаст")
                    .font(.largeTitle)
                    .bold()
                List {
                    Section(content: {
                        TextField("Введите URL адрес RSS файла", text: $url)
                            .preferredColorScheme(.dark)
                    }, header: {
                        Text("RSS")
                    })
                    Section(content: {
                        TextField("Введите URL адрес файла с реакциями", text: $url)
                            .preferredColorScheme(.dark)
                    }, header: {
                        Text("Файл с реакциями")
                    })
                    
                }.cornerRadius(20)
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.top, 15)
            .padding(.horizontal, 25)
        }
    }
}

struct PodcastsView: View {
    @State var podcasts: [Podcast]
    @State var isAdding = false
    
    func lazyLogo() {
        for podcast in $podcasts {
            if podcast.logoCache.wrappedValue == nil {
                ImageLoader(urlString: podcast.wrappedValue.logoUrl, destination: podcast.logoCache)
            }
        }
    }
    
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
            .navigationTitle("Подкасты")
            .navigationBarItems(trailing:
                Button(action: {
                    isAdding = true
                }, label: {
                    Image(systemName: "plus")
                })
            )
            .sheet(isPresented: $isAdding, onDismiss: {
                lazyLogo()
            }) {
                NewPodcastView(podcasts: $podcasts)
            }
        }
        .smartTint(.white)
        .onAppear() {
            lazyLogo()
        }
    }
    
    init() {
        let parser = RSSParser(url: URL(string: "https://vk.com/podcasts-147415323_-1000000.rss")!)
        parser.parse()
        parser.podcast.parseJSON(name: "podcast")
        self.podcasts = [parser.podcast]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
    }
}

struct PodcastsView_Previews: PreviewProvider {
    static var previews: some View {
        PodcastsView()
    }
}
