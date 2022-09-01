//
//  Order.swift
//  MyMemo
//
//  Created by Kihyun Lee on 2022/09/01.
//

import Foundation

struct Order {
    var factor: SortBy
    var reverse: Bool
    
    enum SortBy: String {
        case name
        case creation
        case modification
    }
    
    init(factor: String, reverse: String) {
        self.factor = SortBy(rawValue: factor) ?? .creation
        self.reverse = Bool(reverse) ?? false
    }
}
