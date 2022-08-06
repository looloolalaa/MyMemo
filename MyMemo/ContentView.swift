//
//  ContentView.swift
//  MyMemo
//
//  Created by Kihyun Lee on 2022/07/22.
//

import SwiftUI


struct ContentView: View {
    @EnvironmentObject var memos: Memos
    var body: some View {
        NavigationView {
            VStack {
                ForEach(memos.items, id: \.self) { item in
                    NavigationLink(destination: SecondView(text: item.content, item: item)){
                        MemoIcon(memo: item)
                    }
                }
                NavigationLink(destination: EmptyView()) {
                    EmptyView()
                }
            }
            .navigationTitle("Memo")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Memos())
    }
}
