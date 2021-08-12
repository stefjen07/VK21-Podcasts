//
//  PresentController.swift
//  PresentController
//
//  Created by Евгений on 12.08.2021.
//

import SwiftUI

extension View {
    func uiKitFullPresent<V: View>(isPresented: Binding<Bool>, style: UIModalPresentationStyle = .fullScreen, content: @escaping (_ dismissHandler: @escaping () -> Void) -> V) -> some View {
        self.modifier(FullScreenPresent(isPresented: isPresented, style: style, contentView: content))
    }
}

extension UIViewController {
    static var topMost: UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first

        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
}

struct FullScreenPresent<V: View>: ViewModifier {
    @Binding var isPresented: Bool
    @State private var isAlreadyPresented: Bool = false
    
    let style: UIModalPresentationStyle
    let contentView: (_ dismissHandler: @escaping () -> Void) -> V
    
    @ViewBuilder
    func body(content: Content) -> some View {
        if isPresented {
            content
                .onAppear {
                    if self.isAlreadyPresented == false {
                        let hostingVC = UIHostingController(rootView: self.contentView({
                            self.isPresented = false
                            self.isAlreadyPresented = false
                            UIViewController.topMost?.dismiss(animated: true, completion: nil)
                        }))
                        hostingVC.modalPresentationStyle = self.style
                        UIViewController.topMost?.present(hostingVC, animated: true) {
                            self.isAlreadyPresented = true
                        }
                    }
                }
        } else {
            content
        }
    }
}
