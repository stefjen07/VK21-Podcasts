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

let reactionColors = [
    Color("reaction0"),
    Color("reaction1"),
    Color("reaction2"),
    Color("reaction3"),
    Color("reaction4"),
    Color("reaction5"),
    Color("reaction6")
]

struct StatReactionRow: View {
    @Binding var reactions: [Reaction]
    @Binding var reaction: Reaction
    var views: String
    
    var body: some View {
        HStack(spacing: 5) {
            Button(action: {
                withAnimation {
                    if reaction.statSelectionIdx == nil {
                        for i in 0..<7 {
                            var busy = false
                            for reaction in reactions {
                                if reaction.statSelectionIdx == i {
                                    busy = true
                                    break
                                }
                            }
                            if !busy {
                                reaction.statSelectionIdx = i
                                break
                            }
                        }
                    } else {
                        reaction.statSelectionIdx = nil
                    }
                }
            }, label: {
                Image(systemName: reaction.statSelectionIdx != nil ? "checkmark.circle.fill" : "checkmark.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color("VKColor"))
                    .frame(width: 30, height: 30)
            }).padding(.trailing, 10)
            Text(reaction.emoji)
                .font(.title)
            Text(reaction.description)
                .font(.body)
            Circle()
                .fill(reaction.statSelectionIdx == nil ? .clear : reactionColors[reaction.statSelectionIdx!])
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
            
            HStack(alignment: .center, spacing: 0) {
                Capsule()
                    .fill(color)
                    .frame(width: size.width * relativePercentage, height: 4)
                Spacer(minLength: 0)
            }
        }
    }
}

func preparePercentage(_ value: Double, percentage: Bool) -> String {
    return "\((Double(Int(value*10))/10).removeZerosFromEnd())" + (percentage ? " %" : "")
}

func shortNumber(_ value: Int) -> String {
    if value < 1000 {
        return "\(value)"
    } else if value < 1000000 {
        return preparePercentage(Double(value)/1000, percentage: false)+"K"
    }
    return preparePercentage(Double(value)/1000000, percentage: false)+"M"
}

struct StatCityData {
    var id: Int
    var title: String
    var count: Int
    var percentage: Double
}

struct StatCityRow: View {
    var data: StatCityData
    var maxPercentage: Double
    var color: Color
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            
            HStack(alignment: .center) {
                Text(data.title)
                    .font(.subheadline)
                    .frame(width: size.width * 0.35)
                Text(shortNumber(data.count))
                    .foregroundColor(.init(white: 0.65))
                    .font(.footnote)
                GraphLine(color: color, relativePercentage: data.percentage / maxPercentage)
                Text(preparePercentage(data.percentage * 100, percentage: true))
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

struct CitiesCache {
    var cities: [City]
    
    func cityTitle(id: Int) -> String {
        if let city = cities.first(where: { city in
            return city.id == id
        }) {
            return city.title
        }
        return ""
    }
}

struct AgeGroup {
    
}

struct StatView: View {
    @Environment(\.presentationMode) var presentation: Binding<PresentationMode>
    let malePercentage: Double
    var maleCount: Int
    var peopleCount: Int
    var citiesTop: [StatCityData]
    @State var reactions: [Reaction]
    var maxCityPercentage: Double
    
    func percentageOfFirst(_ k: Int) -> Double {
        var result = Double.zero
        for i in 0..<min(k, citiesTop.count) {
            result += citiesTop[i].percentage
        }
        return result
    }
    
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
                                [1500, 2500, 5000, 3000],
                                [2300, 1200, 3600, 3200],
                                [2500, 2600, 2700, 1900]
                            ], reactions: reactions)
                            ForEach($reactions) { reaction in
                                StatReactionRow(reactions: $reactions, reaction: reaction, views: "4K")
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
                                        Text(shortNumber(maleCount))
                                            .font(.title2)
                                        Circle()
                                            .fill(Color(white: 0.65))
                                            .aspectRatio(1, contentMode: .fit)
                                            .frame(width: 3)
                                        Text(preparePercentage(malePercentage * 100, percentage: true))
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
                                        Text(shortNumber(peopleCount - maleCount))
                                            .font(.title2)
                                        Circle()
                                            .fill(Color(white: 0.65))
                                            .aspectRatio(1, contentMode: .fit)
                                            .frame(width: 3)
                                        Text(preparePercentage((1-malePercentage) * 100, percentage: true))
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
                                    ForEach(0..<citiesTop.count) { i in
                                        PieSliceView(pieSliceData: .init(startAngle: .init(degrees: 360 * percentageOfFirst(i)), endAngle: .init(degrees: 360 * percentageOfFirst(i+1)), color: Color("city\(i)")), borderColor: Color("Background"), selfSize: circleWidth)
                                    }
                                }.frame(width: circleWidth, height: circleWidth)
                                Spacer()
                            }
                            ForEach(0..<citiesTop.count) { i in
                                if i != 0 {
                                    Spacer()
                                        .frame(height: 20)
                                }
                                StatCityRow(data: citiesTop[i], maxPercentage: maxCityPercentage, color: Color("city\(i)"))
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
    
    init(reactions: [Reaction], episode: Episode, citiesCache: CitiesCache) {
        self._reactions = .init(initialValue: reactions)
        maleCount = 0
        peopleCount = 0
        if episode.statistics.count == 0 {
            self.malePercentage = 0
        } else {
            for stat in episode.statistics {
                if stat.sex == .male {
                    maleCount += 1
                }
            }
            peopleCount = episode.statistics.count
            self.malePercentage = Double(maleCount) / Double(peopleCount)
        }
        var citiesTop = [StatCityData]()
        var maxPercentage: Double = 0
        if episode.statistics.count != 0 {
            for stat in episode.statistics {
                var found = false
                for i in 0..<citiesTop.count {
                    if stat.cityId == citiesTop[i].id {
                        found = true
                        citiesTop[i].count += 1
                        break
                    }
                }
                if !found {
                    citiesTop.append(.init(id: stat.cityId, title: citiesCache.cityTitle(id: stat.cityId), count: 1, percentage: 0))
                }
            }
            citiesTop.sort(by: { first, second in
                return first.count >= second.count
            })
            if citiesTop.count > 5 {
                citiesTop.removeSubrange(5..<citiesTop.count)
            }
            var othersCount = episode.statistics.count
            
            for i in 0..<citiesTop.count {
                citiesTop[i].percentage = Double(citiesTop[i].count) / Double(episode.statistics.count)
                othersCount -= citiesTop[i].count
            }
            
            if citiesTop.count == 5 {
                citiesTop.append(.init(id: -1, title: "Другие", count: othersCount, percentage: Double(othersCount)/Double(episode.statistics.count)))
            }
            
            for i in 0..<citiesTop.count {
                maxPercentage = max(maxPercentage, citiesTop[i].percentage)
            }
        }
        self.maxCityPercentage = maxPercentage
        self.citiesTop = citiesTop
    }
}

struct StatView_Previews: PreviewProvider {
    static var previews: some View {
        StatView(reactions: [
            
        ], episode: .init(), citiesCache: .init(cities: []))
    }
}
