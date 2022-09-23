//
//  Texts.swift
//  MyMemo
//
//  Created by Kihyun Lee on 2022/07/31.
//

import Foundation
import SwiftUI

// memo items
class Memos: ObservableObject {
    @Published var items: [Memo] = []
    
    // initial value: Sorted by creation & not reverse
    var order: Order = Order(factor: SortBy.creation, reverse: false)
    
    
    
    // read document files
    init() {
        let fileManager = FileManager()
        
        // 3 folders
        let textFolderURL = fileManager.textFolderURL
        let imageFolderURL = fileManager.imageFolderURL
        let orderFolderURL = fileManager.orderFolderURL
        
        let factorFileURL = fileManager.factorFileURL
        let reverseFileURL = fileManager.reverseFileURL
        
        // create 3 folders
        do {
            // create text folder
            if !fileManager.fileExists(atPath: textFolderURL.path) {
                try fileManager.createDirectory(at: textFolderURL, withIntermediateDirectories: false, attributes: nil)
            }
            
            // create image folder
            if !fileManager.fileExists(atPath: imageFolderURL.path) {
                try fileManager.createDirectory(at: imageFolderURL, withIntermediateDirectories: false, attributes: nil)
            }
            
            // create order folder
            if !fileManager.fileExists(atPath: orderFolderURL.path) {
                try fileManager.createDirectory(at: orderFolderURL, withIntermediateDirectories: false, attributes: nil)
                
                // init factor file & reverse file
                try self.order.factorString.write(to: factorFileURL, atomically: false, encoding: .utf8)
                try self.order.reverseString.write(to: reverseFileURL, atomically: false, encoding: .utf8)
            }
            
            
        } catch {
            print("Error Creating Directory: \(error.localizedDescription)")
        }
            
        
        // read textFolder
        do {
            let allTextFileURLs = try fileManager.contentsOfDirectory(at: textFolderURL, includingPropertiesForKeys: nil)
            
            // read memo item
            for url in allTextFileURLs {
                // "temp.txt"
                let title = url.lastPathComponent
                
                // "this is the sample content!!"
                let content = try String(contentsOf: url, encoding: .utf8)
                
                // uiImage == nil
                var uiImage: UIImage?
                
                let imageFileURL = fileManager.imageFileURL(title: title)
                if fileManager.fileExists(atPath: imageFileURL.path) {
                    if let data = try? Data(contentsOf: imageFileURL), let loaded = UIImage(data: data) {
                        uiImage = loaded
                    }
                }
                
                let attr = try fileManager.attributesOfItem(atPath: url.path)
                
                // 2022-09-14 14:10:45
                let creationDate = attr[FileAttributeKey.creationDate] as! Date
                
                // 2022-09-14 14:10:45
                let modificationDate = attr[FileAttributeKey.modificationDate] as! Date
                
                
                let newMemo = Memo(title: title, content: content, uiImage: uiImage, creationDate: creationDate, modificationDate: modificationDate)
                self.items.append(newMemo)
                
            }
            
            // read order
            let factorString = try String(contentsOf: fileManager.factorFileURL, encoding: .utf8)
            let reverseString = try String(contentsOf: fileManager.reverseFileURL, encoding: .utf8)
           
            // ex) factorString == "name" & reverseString == "true"
            if let factor = SortBy(rawValue: factorString), let reverse = Bool(reverseString) {
                self.order = Order(factor: factor, reverse: reverse)
            }
            
            
        } catch {
            print("Error Reading File: \(error.localizedDescription)")
        }
        
        
        sortByOrder()
    }
    
    func sortByOrder() {
        switch order.factor {
        case .name:
            items.sort { order.reverse ? $0.title > $1.title : $0.title < $1.title }
        case .creation:
            items.sort { order.reverse ? $0.creationDate > $1.creationDate : $0.creationDate < $1.creationDate }
        case .modification:
            items.sort { order.reverse ? $0.modificationDate > $1.modificationDate : $0.modificationDate < $1.modificationDate }
        }
    }
    
    
    func fileExists(newFileName: String) -> Bool {
        let fileManager = FileManager()
        let newFileURL = fileManager.textFileURL(title: newFileName)
        
        return fileManager.fileExists(atPath: newFileURL.path)
    }
    

    func appendNewMemo(newFileName: String) {
        let fileManager = FileManager()
        let newFileURL = fileManager.textFileURL(title: newFileName)
        
        let newFileContent = ""
        let newMemo = Memo(title: newFileName, content: newFileContent, creationDate: Date(), modificationDate: Date())
        
        
        do {
            try newFileContent.write(to: newFileURL, atomically: false, encoding: .utf8)
            self.items.append(newMemo)
            
        } catch {
            print("Error Writing File: \(error.localizedDescription)")
        }
        
        sortByOrder()
        
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
