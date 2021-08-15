//
//  StatView.swift
//  StatView
//
//  Created by Евгений on 14.08.2021.
//

import SwiftUI

struct DataComparingText: View {
    var body: some View {
        HStack {
            Text("Данные сравниваются за одинаковые промежутки времени в прошлом.")
                .font(.footnote)
                .foregroundColor(.init(white: 0.65))
                .multilineTextAlignment(.leading)
            Spacer()
        }.padding(.top, 10)
    }
}

struct StatTitle: View {
    var text: String
    
    var body: some View {
        Text(text)
            .font(.headline)
            .padding(.top, 10)
    }
    
    init(_ text: String) {
        self.text = text
    }
}

struct StatReactionRow: View {
    @State var selected: Bool = true
    var emoji: String
    var description: String
    var views: String
    var graphColor: Color
    var body: some View {
        HStack(spacing: 5) {
            Button(action: {
                selected.toggle()
            }, label: {
                Image(systemName: selected ? "checkmark.circle.fill" : "checkmark.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color("VKColor"))
                    .frame(width: 30, height: 30)
            }).padding(.trailing, 10)
            Text(emoji)
                .font(.title)
            Text(description)
                .font(.body)
            Circle()
                .fill(graphColor)
                .frame(width: 6, height: 6)
                .padding(.leading, 5)
            Spacer()
            Text(views)
                .foregroundColor(.init(white: 0.65))
        }
    }
}

struct GraphLine: View {
    var color: Color
    var relativePercentage: Double
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            
            HStack(spacing: 0) {
                Capsule()
                    .fill(color)
                    .frame(width: size.width * relativePercentage, height: 4)
                Spacer(minLength: 0)
            }
        }
    }
}

struct StatCityRow: View {
    var name: String
    var views: String
    var percentage: Double
    var maxPercentage: Double
    var color: Color
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            
            HStack(alignment: .center) {
                Text(name)
                    .font(.subheadline)
                    .frame(width: size.width * 0.35)
                Text(views)
                    .foregroundColor(.init(white: 0.65))
                    .font(.footnote)
                GraphLine(color: color, relativePercentage: percentage / maxPercentage)
                Text("\((Double(Int(percentage*10))/10).removeZerosFromEnd()) %")
                    .foregroundColor(.init(white: 0.65))
                    .font(.footnote)
            }
        }
    }
}

struct StatAgeRow: View {
    var emojies: [String] = ["👍", "👎", "💩"]
    var description: String = "до 18"
    
    var body: some View {
        HStack(spacing: 20) {
            Text(description)
            HStack(alignment: .center) {
                Text(emojies[0])
                    .font(.title2)
                Text(emojies[1])
                    .font(.subheadline)
                Text(emojies[2])
                    .font(.caption)
            }
        }
    }
}

struct StatView: View {
    @Environment(\.presentationMode) var presentation: Binding<PresentationMode>
    let malePercentage: Double = 0.154
    
    var body: some View {
        ZStack {
            Color("Background")
                .edgesIgnoringSafeArea(.all)
            GeometryReader { proxy in
                let size = proxy.size
                let circleWidth = size.width/2
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        Text("Статистика")
                            .font(.title3)
                            .bold()
                            .padding(.top, 5)
                        Divider()
                        VStack(alignment: .leading) {
                            StatTitle("Реакции")
                            HStack {
                                Text("Динамика реакций на подкаст")
                                    .font(.subheadline)
                                    .foregroundColor(.init(white: 0.65))
                                Spacer()
                                Text("8 %")
                            }
                            GeometryReader { proxy in
                                let size = proxy.size
                                ReactionsGraph(selfSize: size)
                            }.frame(height: 120)
                            HStack {
                                ForEach(0..<9) { i in
                                    if i != 0 {
                                        Spacer()
                                    }
                                    Text("\(i*3<10 ? "0" : "")\(i*3)")
                                        .font(.subheadline)
                                        .foregroundColor(.init(white: 0.65))
                                }
                            }
                        }
                        Divider()
                        VStack(alignment: .leading) {
                            StatTitle("Виды реакций")
                            ReactionTypeGraph(values: [
                                [1000, 2000, 4000, 6000],
                                [1500, 2500, 5000, 3000]
                            ])
                            ForEach(0..<4) { i in
                                StatReactionRow(emoji: "💩", description: "Какой-то бред", views: "\(i+1)K", graphColor: .green)
                            }
                            Button(action: {
                                
                            }, label: {
                                HStack {
                                    Image(systemName: "chevron.down")
                                    Text("Остальные реакции")
                                }.font(.body)
                            })
                                .foregroundColor(Color("VKColor"))
                                .padding(.top, 5)
                                .padding(.horizontal, 8)
                            DataComparingText()
                        }
                        Divider()
                        VStack(alignment: .leading) {
                            StatTitle("Пол и возраст")
                            HStack {
                                Spacer()
                                Circle()
                                    .fill(Color("Female"))
                                    .frame(width: circleWidth, height: circleWidth)
                                    .overlay(
                                        ZStack {
                                            PieSliceView(pieSliceData: .init(startAngle: .init(degrees: 0), endAngle: .init(degrees: 360 * malePercentage), color: Color("Male")), borderColor: Color("Background"), selfSize: circleWidth)
                                            Circle()
                                                .stroke(Color("Background"), lineWidth: 3)
                                        }
                                    )
                                Spacer()
                            }
                            Spacer(minLength: 20)
                            HStack {
                                Spacer()
                                VStack {
                                    HStack {
                                        Circle()
                                            .fill(Color("Male"))
                                            .aspectRatio(1, contentMode: .fit)
                                            .frame(width: 10)
                                        Text("8,4K")
                                            .font(.title2)
                                        Circle()
                                            .fill(Color(white: 0.65))
                                            .aspectRatio(1, contentMode: .fit)
                                            .frame(width: 3)
                                        Text("15.4 %")
                                            .foregroundColor(.init(white: 0.65))
                                            .font(.title2)
                                    }
                                    Text("Мужчины")
                                        .foregroundColor(.init(white: 0.65))
                                        .font(.footnote)
                                }
                                Spacer()
                                VStack {
                                    HStack {
                                        Circle()
                                            .fill(Color("Female"))
                                            .aspectRatio(1, contentMode: .fit)
                                            .frame(width: 10)
                                        Text("18,4K")
                                            .font(.title2)
                                        Circle()
                                            .fill(Color(white: 0.65))
                                            .aspectRatio(1, contentMode: .fit)
                                            .frame(width: 3)
                                        Text("84.6 %")
                                            .foregroundColor(.init(white: 0.65))
                                            .font(.title2)
                                    }
                                    Text("Женщины")
                                        .font(.footnote)
                                        .foregroundColor(.init(white: 0.65))
                                }
                                Spacer()
                            }
                            Divider()
                            ForEach(0..<4) { i in
                                StatAgeRow()
                            }
                            DataComparingText()
                        }
                        Divider()
                        VStack(alignment: .leading) {
                            Button(action: {
                                
                            }, label: {
                                HStack {
                                    StatTitle("Города")
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(Color("VKColor"))
                                        .padding(.top, 10)
                                }
                            })
                            HStack {
                                Spacer()
                                ZStack {
                                    ForEach(0..<6) { i in
                                        PieSliceView(pieSliceData: .init(startAngle: .init(degrees: 0), endAngle: .init(degrees: 360 * malePercentage), color: Color("city0")), borderColor: Color("Background"), selfSize: circleWidth)
                                    }
                                }.frame(width: circleWidth, height: circleWidth)
                                Spacer()
                            }
                            ForEach(0..<6) { i in
                                if i != 0 {
                                    Spacer()
                                        .frame(height: 20)
                                }
                                StatCityRow(name: "Санкт-Петербург", views: "1.4K", percentage: 74.1, maxPercentage: 74.1, color: Color("city\(i)"))
                            }
                            DataComparingText()
                                .padding(.top, 6)
                                .padding(.horizontal, 4)
                        }
                    }
                        .foregroundColor(Color("TitlePrimary"))
                        .padding(.horizontal, 25)
                        .padding(.bottom, 25)
                    Divider()
                    Button(action: {
                        
                    }, label: {
                        Text("Данные за 30 дней")
                        Image(systemName: "chevron.down")
                    }).foregroundColor(Color("VKColor"))
                    Divider()
                }
                .preferredColorScheme(.dark)
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
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.horizontal, 10)
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

struct StatView_Previews: PreviewProvider {
    static var previews: some View {
        StatView()
    }
}
