//
//  ContentView.swift
//  MyMemo
//
//  Created by Kihyun Lee on 2022/07/22.
//

import SwiftUI


struct ContentView: View {
    @StateObject var memos = Memos()
    @State private var showingFileNameField = false
    @State private var newFileName = ""
    @State private var showingAlreadyExist = false
    
    var body: some View {
        NavigationView {
            VStack {
                ForEach(memos.items, id: \.title) { item in
                    NavigationLink(destination: SecondView(memos: memos, text: item.content, item: item)){
                        MemoIcon(memo: item)
                    }
                    .isDetailLink(false)
                    //Prevent pop back
                    //because pushed onto the navigation stack
                }
                
                if showingFileNameField {
                    HStack {
                        TextField("name", text: $newFileName)
                            .padding(4)
                            .frame(width: 80)
                            .border(.gray, width: 1)
                        
                        Button("OK") {
                            if !newFileName.isEmpty {
                                if memos.add(fileName: newFileName) {
                                    newFileName = ""
                                } else {
                                    showingAlreadyExist.toggle()
                                }
                            }
                        }
                    }
                    .alert(isPresented: $showingAlreadyExist) {
                        Alert(title: Text("Already exists"))
                    }
                }
                
                //plus & minus button
                Button(action: {
                    showingFileNameField.toggle()
                }){
                    if showingFileNameField {
                        Image(systemName: "minus.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .padding()
                            .foregroundColor(.red)
                    } else {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .padding()
                    }
                }
                
            }
            .navigationTitle("Memo")
            
        }
        .navigationViewStyle(.stack)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
