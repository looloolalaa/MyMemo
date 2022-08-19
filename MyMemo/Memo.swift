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
    var uiImage: UIImage?
    var content: String
    var url: URL
    
    static let example = Memo(title: "temp.txt", uiImage: UIImage(named: "dice"), content: "Hello, this is sample", url: URL(fileURLWithPath: ""))
}
