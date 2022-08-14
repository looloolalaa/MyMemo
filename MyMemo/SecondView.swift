//
//  TextField.swift
//  MyMemo
//
//  Created by Kihyun Lee on 2022/08/02.
//

import SwiftUI

struct SecondView: View {
    @ObservedObject var memos: Memos
    @State var text: String
    @State private var showingConfirmDeleting: Bool = false
    
    var item: Memo
    
    var body: some View {
        VStack {
            TextEditor(text: $text)
                .padding()
                .frame(minHeight: 40, maxHeight: 400)
                .border(.gray)
                .onChange(of: text) { value in
                    do {
                        //memos update
                        let newMemo = Memo(title: item.title, content: text, url: item.url)
                        memos.change(item: item, newItem: newMemo)

                        //document write
                        try text.write(to: item.url, atomically: false, encoding: .utf8)

                    } catch {
                        print("Error Writing File: \(error.localizedDescription)")
                    }
                }
                //delete button
                .alert(isPresented: $showingConfirmDeleting) {
                    Alert(title: Text("Are you sure?"),
                          primaryButton: .cancel(),
                          secondaryButton: .destructive(Text("Delete")) {
                                do {
                                    //document file delete
                                    let fileManager = FileManager()
                                    try fileManager.removeItem(at: item.url)
                    
                                    //memos update
                                    memos.delete(item: item)
                    
                                } catch {
                                    print("Error Deleting File: \(error.localizedDescription)")
                                }
                          }
                    )
                }
            
            Spacer()
                
        }
        .navigationTitle(item.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingConfirmDeleting.toggle()
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                
            }
        }
        
        
    }
}

struct SecondView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SecondView(memos: Memos(), text: Memo.example.content, item: Memo.example)
        }
    }
}
