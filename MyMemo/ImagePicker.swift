//
//  ImagePicker.swift
//  MyMemo
//
//  Created by Kihyun Lee on 2022/08/19.
//

import Foundation

import PhotosUI
import SwiftUI

struct ImagePickerHandlers {
    let cancelAction: () -> ()
    let imageLoadFailAction: () -> ()
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var uiImage: UIImage?
    let handlers: ImagePickerHandlers
    
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            // result is empty == cancel button clicked
            guard let provider = results.first?.itemProvider else {
                self.parent.handlers.cancelAction()
                return
            }

            // guaranteed results exist == photo clicked
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    if let uiImage = image as? UIImage {
                        self.parent.uiImage = uiImage
                        return
                    } else {
                        self.parent.handlers.imageLoadFailAction()
                        return
                    }
                }
            } else {
                self.parent.handlers.imageLoadFailAction()
                return
            }
            
            
        }
        
    }
    
}
