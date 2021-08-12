//
//  ContentView.swift
//  VKPodcasts
//
//  Created by Евгений on 11.08.2021.
//

import SwiftUI
import VK_ios_sdk

class VKWrapper: NSObject, VKSdkDelegate, VKSdkUIDelegate {
    func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {
        let vc = VKCaptchaViewController.captchaControllerWithError(captchaError)
        presentedController = vc
        isPresented = true
    }
    
    var token: VKAccessToken?
    let sdk: VKSdk
    var authorized = false
    @Binding var presentedController: UIViewController?
    @Binding var isPresented: Bool
    
    func authorize() {
        if let token = token, let accessToken = token.accessToken {
            authorized = true
            let request = VKRequest(method: "stats.trackVisitor", parameters: [
                "access_token": accessToken
            ])
            request?.execute(resultBlock: { response in
                print("Track visitor respond received: \(response?.responseString)")
            }, errorBlock: { error in
                print(error?.localizedDescription)
            })
        }
    }
    
    func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
        if (result.token != nil) {
            token = result.token
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
        token = newToken
    }
    
    func vkSdkShouldPresent(_ controller: UIViewController!) {
        print("Presenting VK controller")
        presentedController = controller
        isPresented = true
    }
    
    func vkSdkWillDismiss(_ controller: UIViewController!) {
        isPresented = false
    }
    
    func register() {
        sdk.register(self)
        VKSdk.instance().uiDelegate = self
    }
    
    init(presentedController: Binding<UIViewController?>, isPresented: Binding<Bool>) {
        self._presentedController = presentedController
        self._isPresented = isPresented
        sdk  = VKSdk.initialize(withAppId: "7925312")
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
    @State var wrapper: VKWrapper? = nil
    
    var body: some View {
        ZStack {
            if isPresented {
                ViewControllerRepresentable(viewController: controller!)
            } else if wrapper == nil {
                EmptyView()
            } else if !wrapper!.authorized {
                LoginView(wrapper: $wrapper)
            } else {
                PlayerView()
            }
        }.onAppear {
            wrapper = VKWrapper(presentedController: $controller, isPresented: $isPresented)
            wrapper?.register()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
