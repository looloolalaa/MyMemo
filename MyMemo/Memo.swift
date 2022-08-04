//
//  Memo.swift
//  MyMemo
//
//  Created by Kihyun Lee on 2022/07/31.
//

import Foundation

struct Memo: Hashable {
    var title: String
    var image: String?
    var content: String
    
    static let example = Memo(title: "temp.txt", content: "Hello, this is sample")
}
