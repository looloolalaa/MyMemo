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
                    .isDetailLink(false)
                    //Prevent pop back
                    //because pushed onto the navigation stack
                }
                
                Button(action: {
                    let newFileName = "file\(memos.itemsCount()+1)"
                    let newFileContent = ""
                    
                    let fileManager = FileManager()
                    let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let dataURL = documentURL.appendingPathComponent(newFileName)
                    
                    let newMemo = Memo(title: newFileName, content: newFileContent, url: dataURL)
                    
                    do {
                        try newFileContent.write(to: dataURL, atomically: false, encoding: .utf8)
                        memos.add(item: newMemo)
                        
                    } catch {
                        print("Error Writing File: \(error.localizedDescription)")
                    }
                    
                    
                }){
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .padding()
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
