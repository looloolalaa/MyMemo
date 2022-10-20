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
    var order: Order = Order(factor: SortBy.creation, reverse: false) {
        willSet(newOrder) {
            let fileManager = FileManager()
            
            do {
                try (newOrder.factor.rawValue).write(to: fileManager.factorFileURL, atomically: false, encoding: .utf8)
                try String(newOrder.reverse).write(to: fileManager.reverseFileURL, atomically: false, encoding: .utf8)
            } catch {
                print("Error Writing File: \(error.localizedDescription)")
            }
        }
        
        didSet {
            sortByOrder()
        }
    }
    
    
    
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
            
        
        // read textFolder & read image
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
                // this does not trigger (willSet & didSet) because it is included in "init()"
            }
            
            
        } catch {
            print("Error Reading File: \(error.localizedDescription)")
        }
        
        
        sortByOrder()
    }
    
    func sortByOrder() {
        withAnimation {
            switch order.factor {
            case .name:
                items.sort { order.reverse ? $0.title > $1.title : $0.title < $1.title }
            case .creation:
                items.sort { order.reverse ? $0.creationDate > $1.creationDate : $0.creationDate < $1.creationDate }
            case .modification:
                items.sort { order.reverse ? $0.modificationDate > $1.modificationDate : $0.modificationDate < $1.modificationDate }
            }
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
        
        do {
            // write new text file: Empty Content
            try "".write(to: newFileURL, atomically: false, encoding: .utf8)
            
            // memos update
            let newMemo = Memo(title: newFileName, content: "", creationDate: Date(), modificationDate: Date())
            self.items.append(newMemo) // this may not reach
            
        } catch {
            print("Error Appending File: \(error.localizedDescription)")
        }
        
        sortByOrder()
        
    }
    
    
    func changeTitle(item: Memo, newTitle: String) {
        let fileManager = FileManager()

        // file name move
        do {
            // text file move
            try fileManager.moveItem(at: item.textFileURL, to: fileManager.textFileURL(title: newTitle))
            
            // image file move
            if let _  = item.uiImage {
                try fileManager.moveItem(at: item.imageFileURL, to: fileManager.imageFileURL(title: newTitle))
            }
    
            
            // memos update
            if let index = items.firstIndex(of: item) {
                items[index].title = newTitle
            }
            
        } catch {
            print("Error Moving File: \(error.localizedDescription)")
        }
        
    }
    
    func changeContent(item: Memo, newContent: String) {
        let fileManager = FileManager()
        
        do {
            // text content change
            try newContent.write(to: item.textFileURL, atomically: false, encoding: .utf8)
            
            // memos update
            if let index = items.firstIndex(of: item) {
                items[index].content = newContent
                
                let attr = try fileManager.attributesOfItem(atPath: item.textFileURL.path)
                let modificationDate = attr[FileAttributeKey.modificationDate] as! Date
                items[index].modificationDate = modificationDate
            }

        } catch {
            print("Error Writing File: \(error.localizedDescription)")
        }
        
        sortByOrder()
    }
 
    
    func delete(item: Memo) {
        let fileManager = FileManager()
        
        do {
            // text file delete
            try fileManager.removeItem(at: item.textFileURL)
            
            // image file delete
            if let _  = item.uiImage {
                try fileManager.removeItem(at: item.imageFileURL)
            }
            
            // memos update
            if let index = items.firstIndex(of: item) {
                items.remove(at: index)
            }

        } catch {
            print("Error Deleting File: \(error.localizedDescription)")
        }
        
    }
    
    func changeUIImage(item: Memo, newUIImage: UIImage?) {
        let fileManager = FileManager()
        
        
        do {
            // image change
            if let newUIImage = newUIImage {
                let imageData = newUIImage.pngData()
                
                try imageData?.write(to: item.imageFileURL)
            } else {
                // image delete
                try fileManager.removeItem(at: item.imageFileURL)
            }
            
            // rewrite text file cause modificationDate
            try item.content.write(to: item.textFileURL, atomically: false, encoding: .utf8)
            
            // memos update
            if let index = items.firstIndex(of: item) {
                items[index].uiImage = newUIImage
                
                let attr = try fileManager.attributesOfItem(atPath: item.textFileURL.path)
                let modificationDate = attr[FileAttributeKey.modificationDate] as! Date
                items[index].modificationDate = modificationDate
            }
            
        } catch {
            print("Error Changing File: \(error.localizedDescription)")
        }
        
        sortByOrder()
    }
    
}
