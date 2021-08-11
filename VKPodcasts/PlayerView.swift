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

struct PlayerView: View {
    @State var currentSpeedId: Int
    @State var volume: Double
    
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
                Circle()
                    .fill(Color("PodcastSample"))
                    .frame(width: size.width/1.5, height: size.width/2)
                    .blur(radius: 50)
                    .offset(x: 0, y: size.height/1.7)
                VStack {
                    HStack {
                        Button(action: {
                            changeSpeed()
                        }, label: {
                            Text(speeds[currentSpeedId].removeZerosFromEnd() + "x")
                                .foregroundColor(.white)
                                .frame(width: 40)
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
                            
                        }, label: {
                            Image(systemName: "pause.fill")
                                .resizable()
                                .foregroundColor(.white)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30)
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
                    HStack {
                        Image(systemName: "speaker.fill")
                            .foregroundColor(Color("ControlSecondary"))
                        Slider(value: $volume, in: 0...1)
                            .accentColor(Color("ControlSecondary"))
                        Image(systemName: "speaker.wave.3.fill")
                            .foregroundColor(Color("ControlSecondary"))
                    }.padding(.horizontal, 10)
                }.padding(.horizontal, 15)
            }
        }
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView(currentSpeedId: 2, volume: 0.7)
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
