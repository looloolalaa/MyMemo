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
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        do {
            //files urls
            let contents = try fileManager.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
            
            for url in contents {
                let title = url.lastPathComponent
                let content = try String(contentsOf: url, encoding: .utf8)
                let memo = Memo(title: title, content: content)
                items.append(memo)
            }
            
        } catch {
            print("Error Reading File: \(error.localizedDescription)")
        }
    }
    
    func change(item: Memo, newItem: Memo) {
        if let index = items.firstIndex(of: item) {
            items.remove(at: index)
            items.insert(newItem, at: index)
        }
    }
}
