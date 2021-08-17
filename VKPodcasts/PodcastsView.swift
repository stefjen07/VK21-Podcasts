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
    @Binding var podcastsStorage: PodcastsStorage
    @Binding var userInfo: UserInfo
    
    var body: some View {
        NavigationLink(destination: PodcastView(podcast: $podcast, podcastsStorage: $podcastsStorage, userInfo: $userInfo)) {
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
    @State var rssStr: String = ""
    @State var reactionsStr: String = ""
    @State var rssUrl: URL?
    @State var reactionsUrl: URL?
    @State var documentPicking = false
    @State var jsonPicking = false
    @Binding var podcastsStorage: PodcastsStorage
    
    @Environment(\.presentationMode) var presentation: Binding<PresentationMode>
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color("Background")
                    .edgesIgnoringSafeArea(.all)
                    .documentPicker(isPresented: $documentPicking, extensions: ["rss"], onCancel: {
                        
                    }, onDocumentPicked: { url in
                        rssUrl = url
                    }).documentPicker(isPresented: $jsonPicking, extensions: ["json"], onCancel: {
                        
                    }, onDocumentPicked: { url in
                        reactionsUrl = url
                    })
                VStack(spacing: 15) {
                    HStack {
                        Button(action: {
                            presentation.wrappedValue.dismiss()
                        }, label: {
                            Text("Отменить")
                        })
                        Spacer()
                        Button(action: {
                            let rssRemoteUrl = URL(string: rssStr)
                            let jsonRemoteUrl = URL(string: reactionsStr)
                            let rssData = (try? Data(contentsOf: rssUrl ?? URL(fileURLWithPath: ""))) ?? Data()
                            let jsonData = (try? Data(contentsOf: reactionsUrl ?? jsonRemoteUrl ?? URL(fileURLWithPath: ""))) ?? Data()
                            let config = StoragePodcastConfig(rssUrl: rssRemoteUrl, rssData: rssData, jsonData: jsonData)
                            podcastsStorage.addPodcast(config: config)
                            presentation.wrappedValue.dismiss()
                        }, label: {
                            Text("Готово")
                        })
                    }
                    Text("Новый подкаст")
                        .font(.largeTitle)
                        .bold()
                    List {
                        Section(content: {
                            Button(action: {
                                documentPicking.toggle()
                            }, label: {
                                Text(rssUrl?.lastPathComponent ?? "Выбрать RSS файл")
                            })
                            TextField("Введите URL адрес RSS файла", text: $rssStr)
                                .preferredColorScheme(.dark)
                                .disabled(rssUrl != nil)
                        }, header: {
                            Text("RSS")
                        })
                        Section(content: {
                            Button(action: {
                                jsonPicking.toggle()
                            }, label: {
                                Text(reactionsUrl?.lastPathComponent ?? "Выбрать файл с реакциями")
                            })
                            TextField("Введите URL адрес файла с реакциями", text: $reactionsStr)
                                .preferredColorScheme(.dark)
                                .disabled(reactionsUrl != nil)
                        }, header: {
                            Text("Файл с реакциями")
                        })
                        
                    }.cornerRadius(20)
                    Spacer()
                }
                .foregroundColor(.white)
                .padding(.top, 15)
                .padding(.horizontal, 25)
            }.frame(height: proxy.size.height)
        }
    }
}

struct PodcastsView: View {
    @State var podcastsStorage = PodcastsStorage()
    @State var isAdding = false
    @Binding var userInfo: UserInfo
    
    func lazyLogo() {
        for podcast in $podcastsStorage.podcasts {
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
                        ForEach($podcastsStorage.podcasts) { podcast in
                            PodcastItem(podcast: podcast, podcastsStorage: $podcastsStorage, userInfo: $userInfo)
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
                NewPodcastView(podcastsStorage: $podcastsStorage)
            }
        }
        .accentColor(.white)
        .onAppear() {
            lazyLogo()
        }
    }
    
    init(userInfo: Binding<UserInfo>) {
        self._userInfo = userInfo
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
    }
}

struct PodcastsView_Previews: PreviewProvider {
    static var previews: some View {
        PodcastsView(userInfo: .constant(.init()))
    }
}

extension UINavigationController {
    open override func viewWillLayoutSubviews() {
        let color = UIColor(Color("Background"))
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(color: color), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage(color: UIColor(Color(white: 0.65).opacity(0.65)), size: .init(width: 1, height: 0.5))
        self.navigationController?.view.backgroundColor = color
    }
}

public extension UIImage {
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
