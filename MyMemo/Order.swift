//
//  Order.swift
//  MyMemo
//
//  Created by Kihyun Lee on 2022/09/01.
//

import Foundation

// sort type
enum SortBy: String, CaseIterable, Identifiable {
    case name
    case creation
    case modification
    
    var id: String { self.rawValue } // ex) id of .creation == "creation"
}

struct Order: Equatable {
    var factor: SortBy
    var reverse: Bool
    
    var factorString: String { factor.rawValue }
    var reverseString: String { String(reverse) }
    
}
