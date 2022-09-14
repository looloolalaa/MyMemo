//
//  MyMemoApp.swift
//  MyMemo
//
//  Created by Kihyun Lee on 2022/07/22.
//

import SwiftUI

@main
struct MyMemoApp: App {
    // share ContentView & SecondView
    @StateObject var memos: Memos = Memos()
    
    var body: some Scene {
        WindowGroup {
            ContentView(memos: memos)
        }
    }
}
