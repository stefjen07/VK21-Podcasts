//
//  PlayerView.swift
//  PlayerView
//
//  Created by Евгений on 11.08.2021.
//

import SwiftUI

var speeds: [Double] = [0.5, 0.75, 1.0, 1.25, 1.5]

struct PlayerView: View {
    @State var currentSpeedId: Int
    @State var volume: Double
    
    var body: some View {
        ZStack {
            Color("Background")
                .edgesIgnoringSafeArea(.all)
            VStack {
                HStack {
                    Button(action: {
                        
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
