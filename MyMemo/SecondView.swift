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
    @State private var showingSaved: Bool = false
    
    var item: Memo
    
    var body: some View {
        VStack {
            TextEditor(text: $text)
                .padding()
                .frame(minHeight: 40, maxHeight: 400)
                .border(.gray)
                
            Button("Save") {
                do {
                    //document write
                    try text.write(to: item.url, atomically: false, encoding: .utf8)
                    
                    //memos update
                    let newMemo = Memo(title: item.title, content: text, url: item.url)
                    memos.change(item: item, newItem: newMemo)
                    
                    self.showingSaved.toggle()
                    
                } catch {
                    print("Error Writing File: \(error.localizedDescription)")
                }
                
            }
            .padding()
            
            Spacer()
        }
        .navigationTitle(item.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    do {
                        //document file delete
                        let fileManager = FileManager()
                        try fileManager.removeItem(at: item.url)
                        
                        //memos update
                        memos.delete(item: item)
                        
                    } catch {
                        print("Error Deleting File: \(error.localizedDescription)")
                    }
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
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
