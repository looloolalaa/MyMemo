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
    var order: Order = Order(factor: "creation", reverse: "false")
    
    
    //read document files
    init() {
        let fileManager = FileManager()
        let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let textsURL = documentURL.appendingPathComponent("texts")
        let imagesURL = documentURL.appendingPathComponent("images")
        
        let orderURL = documentURL.appendingPathComponent("order")
        let factorURL = orderURL.appendingPathComponent("factor")
        let reverseURL = orderURL.appendingPathComponent("reverse")
        
        
        //create folder
        do {
            //texts folder
            if !fileManager.fileExists(atPath: textsURL.path) {
                try fileManager.createDirectory(at: textsURL, withIntermediateDirectories: false, attributes: nil)
            }
            
            //images folder
            if !fileManager.fileExists(atPath: imagesURL.path) {
                try fileManager.createDirectory(at: imagesURL, withIntermediateDirectories: false, attributes: nil)
            }
            
            //order folder
            if !fileManager.fileExists(atPath: orderURL.path) {
                try fileManager.createDirectory(at: orderURL, withIntermediateDirectories: false, attributes: nil)
                
                try "creation".write(to: factorURL, atomically: false, encoding: .utf8)
                try "false".write(to: reverseURL, atomically: false, encoding: .utf8)
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
                let title = url.lastPathComponent
                let content = try String(contentsOf: url, encoding: .utf8)
                var uiImage: UIImage?
                
                let imageURL = imagesURL.appendingPathComponent(title)
                if fileManager.fileExists(atPath: imageURL.path) {
                    if let data = try? Data(contentsOf: imageURL), let loaded = UIImage(data: data) {
                        uiImage = loaded
                    }
                }
                
                let attr = try fileManager.attributesOfItem(atPath: url.path)
                let creationDate = attr[FileAttributeKey.creationDate] as! Date
                let modificationDate = attr[FileAttributeKey.modificationDate] as! Date
                
                let memo = Memo(title: title, content: content, uiImage: uiImage, url: url, creationDate: creationDate, modificationDate: modificationDate)
                self.items.append(memo)
                
                
                let factor = try String(contentsOf: factorURL, encoding: .utf8)
                let reverse = try String(contentsOf: reverseURL, encoding: .utf8)
                
                self.order = Order(factor: factor, reverse: reverse)
            }
            
            
        } catch {
            print("Error Reading File: \(error.localizedDescription)")
        }
        
        
        sortByOrder()
    }
    
    
    func add(fileName: String) -> Bool {
        let newFileName = fileName
        let newFileContent = ""

        let fileManager = FileManager()
        let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let textsURL = documentURL.appendingPathComponent("texts")
        let textURL = textsURL.appendingPathComponent(newFileName)

        let newMemo = Memo(title: newFileName, content: newFileContent, url: textURL, creationDate: Date(), modificationDate: Date())
        
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
    
    
    func sortByOrder() {
        switch order.factor {
        case .name:
            if order.reverse {
                items.sort { $0.title > $1.title }
            } else {
                items.sort { $0.title < $1.title }
            }
        case .creation:
            if order.reverse {
                items.sort { $0.creationDate > $1.creationDate }
            } else {
                items.sort { $0.creationDate < $1.creationDate }
            }
        case .modification:
            if order.reverse {
                items.sort { $0.modificationDate > $1.modificationDate }
            } else {
                items.sort { $0.modificationDate < $1.modificationDate }
            }
        }
    }
}
