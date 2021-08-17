//
//  DocumentPicker.swift
//  DocumentPicker
//
//  Created by Евгений on 17.08.2021.
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct DocumentPicker: UIViewControllerRepresentable {
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker
        var pickerController: UIDocumentPickerViewController
        var presented = false
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.isPresented.toggle()
            if let url = urls.first {
                parent.onDocumentPicked(url)
            }
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.isPresented.toggle()
            parent.onCancel()
        }
        
        init(parent: DocumentPicker) {
            self.parent = parent
            var types = [UTType]()
            for str in parent.extensions {
                if let type = UTType(filenameExtension: str) {
                    types.append(type)
                }
            }
            self.pickerController = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
            super.init()
            pickerController.delegate = self
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    @Binding var isPresented: Bool
    var extensions: [String]
    var onDocumentPicked: (_: URL) -> ()
    var onCancel: () -> ()
    
    init(isPresented: Binding<Bool>, extensions: [String], onCancel: @escaping () -> (), onDocumentPicked: @escaping (_: URL) -> ()) {
        self._isPresented = isPresented
        self.extensions = extensions
        self.onCancel = onCancel
        self.onDocumentPicked = onDocumentPicked
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        let pickerController = context.coordinator.pickerController
        if isPresented && !context.coordinator.presented {
            context.coordinator.presented.toggle()
            uiViewController.present(pickerController, animated: true)
        } else if !isPresented && context.coordinator.presented {
            context.coordinator.presented.toggle()
            pickerController.dismiss(animated: true)
        }
    }
}

extension View {
    func documentPicker(isPresented: Binding<Bool>, extensions: [String] = [], onCancel: @escaping () -> () = { }, onDocumentPicked: @escaping (_: URL) -> () = { _ in }) -> some View {
        Group {
            self
            DocumentPicker(isPresented: isPresented, extensions: extensions, onCancel: onCancel, onDocumentPicked: onDocumentPicked)
        }
    }
}
