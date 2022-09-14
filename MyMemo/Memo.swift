//
//  Memo.swift
//  MyMemo
//
//  Created by Kihyun Lee on 2022/07/31.
//

import Foundation
import UIKit

// memo item
struct Memo: Equatable, Identifiable {
    let id = UUID()
    var title: String
    var content: String
    var uiImage: UIImage?
    var creationDate: Date
    var modificationDate: Date
    
    
    var textFileURL: URL {
        let fileManager = FileManager()
        return fileManager.textFileURL(title: title)
    }
    
    var imageFileURL: URL {
        let fileManager = FileManager()
        return fileManager.imageFileURL(title: title)
    }
    
    // type property example
    static let example: Memo = Memo(title: "temp.txt", content: "Hello, this is sample", uiImage: UIImage(named: "dice"), creationDate: Date(), modificationDate: Date())
}


extension Date {
    var getString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // good to see
        return dateFormatter.string(from: self)
    }
}
