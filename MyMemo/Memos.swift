//
//  Texts.swift
//  MyMemo
//
//  Created by Kihyun Lee on 2022/07/31.
//

import Foundation
import SwiftUI

class Memos: ObservableObject {
    @Published var items: [Memo] = []
    
    //read document files
    init() {
        let fileManager = FileManager()
        let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let textsURL = documentURL.appendingPathComponent("texts")
        let imagesURL = documentURL.appendingPathComponent("images")
        
        
        //create folder
        do {
            //texts folder
            if !fileManager.fileExists(atPath: textsURL.path) {
                try fileManager.createDirectory(at: textsURL, withIntermediateDirectories: false, attributes: nil)
            } else {
                print("texts directory exists")
            }
            
            //images folder
            if !fileManager.fileExists(atPath: imagesURL.path) {
                try fileManager.createDirectory(at: imagesURL, withIntermediateDirectories: false, attributes: nil)
            } else {
                print("images directory exists")
            }
            
        } catch {
            print("Error Creating Directory: \(error.localizedDescription)")
        }
            
        
        //read texts
        do {
            //files urls
            let allTextFileURLs = try fileManager.contentsOfDirectory(at: textsURL, includingPropertiesForKeys: nil)
            
            //memo item
            for url in allTextFileURLs {
                let attr = try fileManager.attributesOfItem(atPath: url.path)
                print(attr[FileAttributeKey.creationDate] as? Date)
                
                let title = url.lastPathComponent
                let content = try String(contentsOf: url, encoding: .utf8)
                var uiImage: UIImage?
                
                let imageURL = imagesURL.appendingPathComponent(title)
                if fileManager.fileExists(atPath: imageURL.path) {
                    if let data = try? Data(contentsOf: imageURL), let loaded = UIImage(data: data) {
                        uiImage = loaded
                    }
                }
                
                let memo = Memo(title: title, content: content, uiImage: uiImage, url: url)
                items.append(memo)
            }
            
        } catch {
            print("Error Reading File: \(error.localizedDescription)")
        }
    }
    
    
    func add(fileName: String) -> Bool {
        let newFileName = fileName
        let newFileContent = ""

        let fileManager = FileManager()
        let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let textsURL = documentURL.appendingPathComponent("texts")
        let textURL = textsURL.appendingPathComponent(newFileName)

        let newMemo = Memo(title: newFileName, content: newFileContent, url: textURL)
        
        //already exist
        if fileManager.fileExists(atPath: textURL.path) {
            return false
        }
            
        do {
            items.append(newMemo)
            try newFileContent.write(to: textURL, atomically: false, encoding: .utf8)

        } catch {
            print("Error Writing File: \(error.localizedDescription)")
        }
        return true
    }
    
    func delete(item: Memo) {
        if let index = items.firstIndex(of: item) {
            items.remove(at: index)
        }
    }
    
    func change(item: Memo, newItem: Memo) {
        if let index = items.firstIndex(of: item) {
            items[index] = newItem
        }
    }
}
