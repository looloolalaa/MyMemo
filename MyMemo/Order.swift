//
//  Order.swift
//  MyMemo
//
//  Created by Kihyun Lee on 2022/09/01.
//

import Foundation

enum SortBy: String, CaseIterable, Identifiable {
    case name
    case creation
    case modification
    
    var id: String { self.rawValue }
}

struct Order: Equatable {
    var factor: SortBy
    var reverse: Bool
    
    init() {
        self.factor = .creation
        self.reverse = false
    }
    
    init(factor: String, reverse: String) {
        self.init()
        if let factor = SortBy(rawValue: factor) { self.factor = factor }
        if let reverse = Bool(reverse) { self.reverse = reverse }
    }
    
    static let example = Order()
}
