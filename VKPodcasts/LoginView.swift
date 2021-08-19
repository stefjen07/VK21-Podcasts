//
//  LoginView.swift
//  LoginView
//
//  Created by Евгений on 12.08.2021.
//

import SwiftUI
import VK_ios_sdk

struct LoginView: View {
    @Binding var wrapper: VKWrapper?
    
    var body: some View {
        ZStack {
            Color("Background")
                .edgesIgnoringSafeArea(.all)
            if wrapper != nil {
                Button(action: {
                    VKSdk.authorize(nil)
                }, label: {
                    Text("vk-auth")
                        .foregroundColor(.primary)
                        .padding(10)
                        .background(Color("VKColor"))
                        .cornerRadius(10)
                })
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(wrapper: .constant(nil))
    }
}
