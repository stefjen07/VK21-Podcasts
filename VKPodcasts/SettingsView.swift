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
                        StatTitle("cmn-info")
                        InfoRow(title: "fullname", value: "\(userInfo.firstName) \(userInfo.lastName)")
                        InfoRow(title: "age", value: "\(userInfo.age)")
                        InfoRow(title: "sex", value: String(format: NSLocalizedString(userInfo.sex == .male ? "sex-male" : "sex-female", comment: "")))
                    }
                    VStack(alignment: .leading, spacing: 10) {
                        StatTitle("personal-stat")
                        InfoRow(title: "given-reacts", value: String(statStorage.countForInterval(dataTimeIntervals[selectedTimeInterval].timeInterval)))
                    }
                    VStack(spacing: 10) {
                        Divider()
                        Picker(selection: $selectedTimeInterval, content: {
                            ForEach(0..<dataTimeIntervals.count) { i in
                                Text("data-interval \(String(format: NSLocalizedString(dataTimeIntervals[i].description, comment: "")))")
                                    .foregroundColor(Color("VKColor"))
                                    .tag(i)
                            }
                        }, label: {
                            Text("data-interval \(String(format: NSLocalizedString(dataTimeIntervals[selectedTimeInterval].description, comment: "")))")
                                .foregroundColor(Color("VKColor"))
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
                        Text("sign-out")
                    }).foregroundColor(.red)
                }
                .foregroundColor(.primary)
                .padding(.top, 40)
                .padding(.horizontal, 20)
            }
        }
        .navigationBarTitle("settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(userInfo: .constant(.init()), podcastsStorage: .constant(.init()), authorized: .constant(true))
    }
}
