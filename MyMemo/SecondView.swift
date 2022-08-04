//
//  TextField.swift
//  MyMemo
//
//  Created by Kihyun Lee on 2022/08/02.
//

import SwiftUI

struct SecondView: View {
    @EnvironmentObject var memos: Memos
    @State var text: String
    @State private var showingSaved = false
    var item: Memo
    
    var body: some View {
        VStack {
            TextEditor(text: $text)
                .padding()
            Spacer()
        }
        .navigationTitle(item.title)
        .navigationBarTitleDisplayMode(.automatic)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    let fileManager = FileManager()
                    let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let dataUrl = documentDirectory.appendingPathComponent(item.title)
                    
                    do {
                        //document write
                        try text.write(to: dataUrl, atomically: false, encoding: .utf8)
                        
                        //memos update
                        let newMemo = Memo(title: item.title, content: text)
                        memos.change(item: item, newItem: newMemo)
                        
                        showingSaved.toggle()
                    } catch {
                        print("Error Writing File: \(error.localizedDescription)")
                    }
                }
            }
        }
        .alert(isPresented: $showingSaved) {
            Alert(title: Text("Saved!"))
        }
    }
}

struct SecondView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SecondView(text: Memo.example.content, item: Memo.example)
                .environmentObject(Memos())
        }
    }
}
