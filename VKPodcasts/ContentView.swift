//
//  ContentView.swift
//  VKPodcasts
//
//  Created by Евгений on 11.08.2021.
//

import SwiftUI
import VK_ios_sdk

class VKWrapper: NSObject, VKSdkDelegate, VKSdkUIDelegate {
    @Binding var presentedController: UIViewController?
    @Binding var isPresented: Bool
    
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
        authorized = true
        let request = VKRequest(method: "stats.trackVisitor", parameters: [
            "access_token": VKSdk.accessToken().accessToken ?? ""
        ])
        request?.execute(resultBlock: { response in
            print("Track visitor respond received: \(response?.responseString)")
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

    
    init(presentedController: Binding<UIViewController?>, isPresented: Binding<Bool>, authorized: Binding<Bool>) {
        self._presentedController = presentedController
        self._isPresented = isPresented
        self._authorized = authorized
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
    @State var wrapper: VKWrapper?
    
    var body: some View {
        ZStack {
            if isPresented {
                ViewControllerRepresentable(viewController: controller!)
            } else {
                if authorized {
                    PodcastsView()
                } else {
                    LoginView(wrapper: $wrapper)
                }
            }
        }.onAppear {
            wrapper = VKWrapper(presentedController: $controller, isPresented: $isPresented, authorized: $authorized)
            VKSdk.initialize(withAppId: "7925312").register(wrapper)
            VKSdk.instance().uiDelegate = wrapper
            VKSdk.wakeUpSession(nil, complete: { state, error in
                if state == .authorized {
                    wrapper?.authorize()
                } else if let error = error {
                    print(error.localizedDescription)
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
