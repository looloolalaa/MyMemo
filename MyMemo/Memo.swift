//
//  Memo.swift
//  MyMemo
//
//  Created by Kihyun Lee on 2022/07/31.
//

import Foundation
import UIKit

struct Memo: Hashable {
    var title: String
    var content: String
    var uiImage: UIImage?
    var url: URL
    
    static let example = Memo(title: "temp.txt", content: "Hello, this is sample", uiImage: UIImage(named: "dice"), url: URL(fileURLWithPath: ""))
}
