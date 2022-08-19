//
//  Texts.swift
//  MyMemo
//
//  Created by Kihyun Lee on 2022/07/31.
//

import Foundation

class Memos: ObservableObject {
    @Published var items: [Memo] = []
    
    //read document files
    init() {
        let fileManager = FileManager()
        
        //document url
        let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        do {
            //files urls
            let allFileURLs = try fileManager.contentsOfDirectory(at: documentURL, includingPropertiesForKeys: nil)
            
            //memo item
            for url in allFileURLs {
                let title = url.lastPathComponent
                let content = try String(contentsOf: url, encoding: .utf8)
                let memo = Memo(title: title, content: content, url: url)
                items.append(memo)
            }
            
        } catch {
            print("Error Reading File: \(error.localizedDescription)")
        }
    }
    
    
    
    func itemsCount() -> Int {
        return items.count
    }
    
    func add(fileName: String) -> Bool {
        let newFileName = fileName
        let newFileContent = ""

        let fileManager = FileManager()
        let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dataURL = documentURL.appendingPathComponent(newFileName)

        let newMemo = Memo(title: newFileName, content: newFileContent, url: dataURL)
        
        //already exist
        if fileManager.fileExists(atPath: dataURL.path) {
            return false
        }
            
        do {
            try newFileContent.write(to: dataURL, atomically: false, encoding: .utf8)
            items.append(newMemo)

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
