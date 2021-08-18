//
//  ContentView.swift
//  VKPodcasts
//
//  Created by Евгений on 11.08.2021.
//

import SwiftUI
import VK_ios_sdk

struct UserResponse: Codable {
    var first_name, last_name, bdate: String
    var sex: Int
    var city: City
    
    mutating func fixBdate() {
        if bdate.count > 1 {
            if bdate[bdate.index(bdate.startIndex, offsetBy: 1)] == "." {
                bdate = "0" + bdate
            }
        }
        
        if bdate.count > 6 {
            if bdate[bdate.index(bdate.startIndex, offsetBy: 4)] == "." {
                bdate = bdate.dropFirst(3) + "0" + bdate.dropLast(4)
            }
        }
    }
}

struct UsersResponse: Codable {
    var response: [UserResponse]
}

class VKWrapper: NSObject, VKSdkDelegate, VKSdkUIDelegate {
    @Binding var presentedController: UIViewController?
    @Binding var isPresented: Bool
    @Binding var userInfo: UserInfo
    
    func showVC(_ controller: UIViewController) {
        presentedController = controller
        isPresented = true
    }
    
    func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {
        if let vc = VKCaptchaViewController.captchaControllerWithError(captchaError) {
            showVC(vc)
        }
    }
    
    @Binding var authorized: Bool
    
    func authorize() {
        withAnimation {
            authorized = true
            isPresented = false
        }
        let request = VKRequest(method: "stats.trackVisitor", parameters: [
            "access_token": VKSdk.accessToken().accessToken ?? ""
        ])
        request?.execute(resultBlock: { response in
            if let response = response {
                print("Track visitor respond received: \(response.responseString)")
            }
        }, errorBlock: { error in
            if let error = error {
                print(error.localizedDescription)
            }
        })
        let userRequest = VKRequest(method: "users.get", parameters: [
            "access_token": VKSdk.accessToken().accessToken ?? "",
            "user_ids": [VKSdk.accessToken().userId],
            "fields": ["bdate","sex","city"],
            "name_case": "nom"
        ])
        userRequest?.execute(resultBlock: { response in
            if let json = try? JSONDecoder().decode(UsersResponse.self, from: response!.responseString.data(using: .utf8) ?? Data()) {
                if var userInfo = json.response.first {
                    userInfo.fixBdate()
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd.MM.yyyy"
                    
                    self.userInfo.firstName = userInfo.first_name
                    self.userInfo.lastName = userInfo.last_name
                    self.userInfo.cityId = userInfo.city.id
                    self.userInfo.sex = userInfo.sex == 1 ? .female : .male
                    self.userInfo.age = Int(Date().timeIntervalSince(formatter.date(from: userInfo.bdate) ?? Date()) / (365.25*24*60*60))
                    self.userInfo.ageMajority = self.userInfo.age  >= 18
                }
            }
            
            print("Age: \(self.userInfo.age)")
            print("Majority: \(self.userInfo.ageMajority)")
            print("City id: \(self.userInfo.cityId)")
            print("Sex: \(self.userInfo.sex.rawValue)")
        }, errorBlock: { error in
            print(error?.localizedDescription)
        })
    }
    
    func vkSdkTokenHasExpired(_ expiredToken: VKAccessToken!) {
        VKSdk.authorize(nil)
    }
    
    func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
        if (result.token != nil) {
            authorize()
        } else if (result.error != nil) {
            print(result.error.localizedDescription)
            authorized = false
        }
    }
    
    func vkSdkUserAuthorizationFailed() {
        print("Authorization failed")
        authorized = false
    }
    
    func vkSdkAccessTokenUpdated(_ newToken: VKAccessToken!, oldToken: VKAccessToken!) {
        
    }
    
    func vkSdkShouldPresent(_ controller: UIViewController!) {
        print("Presenting VK controller")
        showVC(controller)
    }

    
    init(presentedController: Binding<UIViewController?>, isPresented: Binding<Bool>, authorized: Binding<Bool>, userInfo: Binding<UserInfo>) {
        self._presentedController = presentedController
        self._isPresented = isPresented
        self._authorized = authorized
        self._userInfo = userInfo
    }
}

struct ViewControllerRepresentable: UIViewControllerRepresentable {
    let viewController: UIViewController
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        return viewController
    }
}

struct ContentView: View {
    @State var controller: UIViewController? = nil
    @State var isPresented = false
    @State var authorized = false
    @State var initialized = false
    @State var userInfo = UserInfo()
    @State var wrapper: VKWrapper?
    
    var body: some View {
        ZStack {
            if isPresented {
                ViewControllerRepresentable(viewController: controller!)
            } else {
                if authorized {
                    PodcastsView(userInfo: $userInfo, authorized: $authorized)
                } else if initialized {
                    LoginView(wrapper: $wrapper)
                } else {
                    Color("Background")
                        .edgesIgnoringSafeArea(.all)
                }
            }
        }.onAppear {
            wrapper = VKWrapper(presentedController: $controller, isPresented: $isPresented, authorized: $authorized, userInfo: $userInfo)
            VKSdk.initialize(withAppId: "7925312").register(wrapper)
            VKSdk.instance().uiDelegate = wrapper
            VKSdk.wakeUpSession(nil, complete: { state, error in
                if state == .authorized {
                    wrapper?.authorize()
                } else if let error = error {
                    print(error.localizedDescription)
                }
                withAnimation {
                    initialized = true
                }
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
