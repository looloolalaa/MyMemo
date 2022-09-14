//
//  URLFunction.swift
//  MyMemo
//
//  Created by Kihyun Lee on 2022/09/14.
//

import Foundation
import SwiftUI


extension FileManager {
    var documentURL: URL { self.urls(for: .documentDirectory, in: .userDomainMask).first! }
    var textFolderURL: URL { documentURL.appendingPathComponent("textFolder") }
    var imageFolderURL: URL { documentURL.appendingPathComponent("imageFolder") }
    var orderFolderURL: URL { documentURL.appendingPathComponent("orderFolder") }
    var factorFileURL: URL { orderFolderURL.appendingPathComponent("factor") }
    var reverseFileURL: URL { orderFolderURL.appendingPathComponent("reverse") }
    
    func textFileURL(title: String) -> URL { textFolderURL.appendingPathComponent(title) }
    func imageFileURL(title: String) -> URL { imageFolderURL.appendingPathComponent(title) }
}
