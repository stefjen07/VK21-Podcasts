//
//  SettingsView.swift
//  SettingsView
//
//  Created by Евгений on 18.08.2021.
//

import SwiftUI
import VK_ios_sdk

struct SettingsView: View {
    @Binding var userInfo: UserInfo
    @Binding var podcastsStorage: PodcastsStorage
    @Binding var authorized: Bool
    @State var selectedTimeInterval = 0
    
    var body: some View {
        ZStack {
            Color("Background")
                .edgesIgnoringSafeArea(.all)
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        StatTitle("Основная информация")
                        InfoRow(title: "Имя и фамилия", value: "\(userInfo.firstName) \(userInfo.lastName)")
                        InfoRow(title: "Возраст", value: "\(userInfo.age)")
                        InfoRow(title: "Пол", value: "\(userInfo.sex == .male ? "Мужской" : "Женский")")
                    }
                    VStack(alignment: .leading, spacing: 10) {
                        StatTitle("Персональная статистика")
                        InfoRow(title: "Оставленные реакции", value: String(statStorage.countForInterval(dataTimeIntervals[selectedTimeInterval].timeInterval)))
                    }
                    VStack(spacing: 10) {
                        Divider()
                        Picker(selection: $selectedTimeInterval, content: {
                            ForEach(0..<dataTimeIntervals.count) { i in
                                Text("Данные за \(dataTimeIntervals[i].description)")
                                    .foregroundColor(Color("VKColor"))
                                    .tag(i)
                            }
                        }, label: {
                            Text("Данные за \(dataTimeIntervals[selectedTimeInterval].description)")
                            Image(systemName: "chevron.down")
                        })
                            .accentColor(Color("VKColor"))
                            .pickerStyle(MenuPickerStyle())
                        Divider()
                    }
                    Button(action: {
                        VKSdk.forceLogout()
                        withAnimation {
                            authorized = false
                        }
                    }, label: {
                        Text("Выйти")
                    }).foregroundColor(.red)
                }
                .foregroundColor(.white)
                .padding(.top, 40)
                .padding(.horizontal, 20)
            }.preferredColorScheme(.dark)
        }
        .navigationBarTitle("Настройки")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(userInfo: .constant(.init()), podcastsStorage: .constant(.init()), authorized: .constant(true))
    }
}
