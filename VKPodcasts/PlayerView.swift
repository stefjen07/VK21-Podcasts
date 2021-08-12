//
//  PlayerView.swift
//  PlayerView
//
//  Created by Евгений on 11.08.2021.
//

import SwiftUI

var speeds: [Double] = [0.5, 0.75, 1.0, 1.25, 1.5]

func createGradient(opacities: [Double]) -> LinearGradient {
    var colors = [Color]()
    for i in opacities {
        colors.append(Color("Background").opacity(i))
    }
    return LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
}

struct BottomSheetView<Content: View>: View {
    @Binding var isOpen: Bool
    
    let radius: CGFloat = 30
    let snapRatio: CGFloat = 0.5
    let minHeightRatio: CGFloat = 0.5
    
    let indicatorWidth: CGFloat = 65
    let indicatorHeight: CGFloat = 5

    let maxHeight: CGFloat
    let minHeight: CGFloat
    let content: Content
    
    private var offset: CGFloat {
        isOpen ? 0 : maxHeight - minHeight
    }

    private var indicator: some View {
        RoundedRectangle(cornerRadius: radius)
            .fill(Color.secondary)
            .frame(
                width: indicatorWidth,
                height: indicatorHeight)
    }

    @GestureState private var translation: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                self.indicator
                    .padding(15)
                    .preferredColorScheme(.dark)
                self.content
            }
            .frame(width: geometry.size.width, height: self.maxHeight, alignment: .top)
            .background(Blur(effect: UIBlurEffect(style: .dark)))
            .cornerRadius(radius)
            .frame(height: geometry.size.height, alignment: .bottom)
            .shadow(color: .white, radius: 2)
            .offset(y: max(self.offset + self.translation, 0))
            .animation(.interactiveSpring(), value: isOpen)
            .animation(.interactiveSpring(), value: translation)
            .gesture(
                DragGesture().updating(self.$translation) { value, state, _ in
                    state = value.translation.height
                }.onEnded { value in
                    let snapDistance = self.maxHeight * snapRatio
                    guard abs(value.translation.height) > snapDistance else {
                        return
                    }
                    self.isOpen = value.translation.height < 0
                }
            )
        }
    }

    init(isOpen: Binding<Bool>, maxHeight: CGFloat, @ViewBuilder content: () -> Content) {
        self.minHeight = maxHeight * minHeightRatio
        self.maxHeight = maxHeight
        self.content = content()
        self._isOpen = isOpen
    }
}

class CustomSlider: UISlider {
    @IBInspectable var trackHeight: CGFloat = 3
    @IBInspectable var thumbRadius: CGFloat = 20

    private lazy var thumbView: UIView = {
        let thumb = UIView()
        thumb.backgroundColor = UIColor(named: "VKColor")
        return thumb
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        let thumb = thumbImage(radius: thumbRadius)
        setThumbImage(thumb, for: .normal)
    }

    private func thumbImage(radius: CGFloat) -> UIImage {
        thumbView.frame = CGRect(x: 0, y: radius / 2, width: radius, height: radius)
        thumbView.layer.cornerRadius = radius / 2

        let renderer = UIGraphicsImageRenderer(bounds: thumbView.bounds)
        return renderer.image { rendererContext in
            thumbView.layer.render(in: rendererContext.cgContext)
        }
    }

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var newRect = super.trackRect(forBounds: bounds)
        newRect.size.height = trackHeight
        return newRect
    }

}

struct SliderRepresentable: UIViewRepresentable {
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    func makeUIView(context: Context) -> some UIView {
        let slider = CustomSlider()
        slider.thumbRadius = 15
        slider.awakeFromNib()
        slider.minimumTrackTintColor = .init(named: "VKColor")
        slider.maximumTrackTintColor = .init(Color("VKColor").opacity(0.2))
        return slider
    }
}

struct Blur: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}

struct PlayerView: View {
    @State var currentSpeedId: Int
    @State var volume: Double
    @State var paused: Bool
    @State var isBottomSheetOpened = false
    @ObservedObject var podcast: Podcast
    @State var logo: Image?
    @ObservedObject var logoLoader: ImageLoader
    
    func changeSpeed() {
        if(currentSpeedId == speeds.count-1) {
            currentSpeedId = 0
        } else {
            currentSpeedId += 1
        }
    }
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let iconSize = size.height * 0.15
            
            ZStack {
                Color("Background")
                    .edgesIgnoringSafeArea(.all)
                VStack(spacing: 0) {
                    Ellipse()
                        .fill(Color("PodcastSample"))
                        .frame(width: size.width/1.2, height: 150)
                        .blur(radius: 40)
                        .offset(x: 0, y: -50)
                    Spacer()
                }
                VStack(spacing: 0) {
                    createGradient(opacities: [0,0.3,0.5,0.675,0.8,0.9,0.95,1])
                        .frame(width: size.width, height: size.width/1.7)
                    Color("Background")
                }
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        if let logo = logo {
                            logo
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: iconSize, height: iconSize)
                                .cornerRadius(iconSize * 0.12)
                                .shadow(radius: 10)
                                .padding(.top, 20)
                                .padding(.bottom, 20)
                        } else {
                            Color.gray.opacity(0.3)
                                .frame(width: iconSize, height: iconSize)
                                .cornerRadius(iconSize * 0.12)
                                .shadow(radius: 10)
                                .padding(.top, 20)
                                .padding(.bottom, 20)
                        }
                        Text(podcast.title)
                            .font(.title)
                            .bold()
                            .lineLimit(1)
                            .foregroundColor(.init("TitlePrimary"))
                            .padding(.horizontal, 5)
                        Text("Команда ВКонтакте")
                            .foregroundColor(.init("VKColor"))
                            .font(.title3)
                            .bold()
                            .padding(.top, 10)
                        Spacer()
                        VStack {
                            GeometryReader { proxy in
                                let size = proxy.size
                                
                                EmojiGraph(selfSize: size)
                            }
                            .frame(height: 20)
                            GeometryReader { proxy in
                                let size = proxy.size
                                
                                ReactionsGraph(selfSize: size)
                            }
                            SliderRepresentable()
                            HStack {
                                Text("0:00")
                                Spacer()
                                Text("-12:34")
                            }.foregroundColor(.init("SecondaryText"))
                        }
                        .padding(10)
                        .padding(.horizontal, 10)
                        .background(Color("SecondaryBackground"))
                        .cornerRadius(10)
                        Spacer()
                            .frame(minHeight: 25)
                        HStack {
                            Button(action: {
                                changeSpeed()
                            }, label: {
                                Text(speeds[currentSpeedId].removeZerosFromEnd() + "x")
                                    .foregroundColor(.white)
                                    .frame(width: 50)
                                    .overlay(Capsule().stroke(Color("ControlSecondary")))
                            })
                            Spacer()
                            Button(action: {
                                
                            }, label: {
                                Image(systemName: "gobackward.15")
                                    .resizable()
                                    .foregroundColor(.white)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30)
                            })
                            Spacer()
                            Button(action: {
                                paused.toggle()
                            }, label: {
                                Image(systemName: paused ? "play.fill" : "pause.fill")
                                    .resizable()
                                    .foregroundColor(.white)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 34)
                            })
                            Spacer()
                            Button(action: {
                                
                            }, label: {
                                Image(systemName: "goforward.15")
                                    .resizable()
                                    .foregroundColor(.white)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30)
                            })
                            Spacer()
                            Button(action: {
                                
                            }, label: {
                                Image(systemName: "ellipsis")
                                    .resizable()
                                    .foregroundColor(.white)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20)
                            })
                        }
                        Spacer()
                        HStack {
                            Image(systemName: "speaker.fill")
                                .foregroundColor(Color("ControlSecondary"))
                            Slider(value: $volume, in: 0...1)
                                .accentColor(Color("ControlSecondary"))
                            Image(systemName: "speaker.wave.3.fill")
                                .foregroundColor(Color("ControlSecondary"))
                        }.padding(.horizontal, 10)
                        Spacer()
                            .frame(height: size.height*0.45-proxy.safeAreaInsets.bottom)
                    }
                    .padding(.horizontal, 15)
                    .onReceive(logoLoader.didChange) { data in
                        if let uiImage = UIImage(data: data) {
                            self.logo = Image(uiImage: uiImage)
                        }
                    }
                }
                VStack {
                    HStack {
                        Button(action: {
                            
                        }, label: {
                            Image(systemName: "chevron.backward")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(5)
                                .frame(height: 30)
                        })
                        Spacer()
                        Button(action: {
                            
                        }, label: {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .padding(5)
                                .frame(height: 30)
                        })
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 15)
                    .padding(.top, 5)
                    Spacer()
                    Ellipse()
                        .fill(Color("PodcastSample"))
                        .frame(width: size.width/1.2, height: size.width/2.4)
                        .blur(radius: 20)
                        .offset(x: 0, y: size.width/12)
                }
                BottomSheetView(isOpen: $isBottomSheetOpened, maxHeight: size.height * 0.8) {
                    ZStack {
                        VStack {
                            Text("Реакции")
                                .font(.title)
                                .bold()
                                .foregroundColor(.white)
                            LazyVGrid(columns: [.init(.adaptive(minimum: 80, maximum: 100))], spacing: 20) {
                                ForEach(0..<8) { _ in
                                    ReactionItem(emoji: "👍")
                                }
                            }.padding(.horizontal, 15)
                        }
                    }
                }.edgesIgnoringSafeArea(.all)
            }
        }
    }
    
    init() {
        let parser = RSSParser(url: URL(string: "https://vk.com/podcasts-147415323_-1000000.rss")!)
        parser.parse()
        let parsedPodcast = parser.podcasts.first!
        self.currentSpeedId = 2
        self.volume = 0.7
        self.paused = true
        logoLoader = ImageLoader(urlString: parsedPodcast.logoUrl)
        self.podcast = parsedPodcast
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView()
    }
}

extension Double {
    func removeZerosFromEnd() -> String {
        let formatter = NumberFormatter()
        let number = NSNumber(value: self)
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return String(formatter.string(from: number) ?? "\(self)")
    }
}
