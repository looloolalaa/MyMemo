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
    let imageLoadTimerInit: () -> ()
    let imageLoadTimerStart: () -> ()
    let maxImageLoadTime: Int
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var uiImage: UIImage?
    @Binding var imageLoadBlock: Bool
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

            // cancel button clicked == result is empty
            guard let provider = results.first?.itemProvider else {
                self.parent.handlers.cancelAction()
                return
            }

            // photo clicked == guaranteed results exist
            if provider.canLoadObject(ofClass: UIImage.self) {
                
                // already in loading first image
                guard self.parent.imageLoadBlock == false else { return }
                
                // can enter loading
                self.parent.imageLoadBlock = true
                self.parent.handlers.imageLoadTimerStart()
                let imageLoadStartTime = CFAbsoluteTimeGetCurrent()
                
                // async func
                provider.loadObject(ofClass: UIImage.self) { image, error in // completionHandler
                    
                    // image loading done
                    let imageLoadEndTime = CFAbsoluteTimeGetCurrent()
                    let totalImageLoadTime = imageLoadEndTime - imageLoadStartTime
                    
                    // time out
                    guard totalImageLoadTime < Double(self.parent.handlers.maxImageLoadTime) else { return }
                    
                    // in time
                    self.parent.imageLoadBlock = false
                    self.parent.handlers.imageLoadTimerInit()
                    
                    
                    // load fail
                    guard error == nil, let uiImage = image as? UIImage else {
                        self.parent.handlers.imageLoadFailAction()
                        return
                    }
                    
                    // all success: in time && no error && casting success
                    self.parent.uiImage = uiImage
                    return
                    
                }
            } else { // can not load image
                self.parent.handlers.imageLoadFailAction()
                return
            }
            
            
        }
        
    }
    
}
