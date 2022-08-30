//
//  ContentView.swift
//  MyMemo
//
//  Created by Kihyun Lee on 2022/07/22.
//

import SwiftUI


struct ContentView: View {
    @StateObject var memos = Memos()
    @State private var newFileName = ""
    
    @State private var showingFileNameField = false
    @State private var showingAlreadyExist = false
    
    let layout = [
        GridItem(.flexible(maximum: 100)),
        GridItem(.flexible(maximum: 100)),
        GridItem(.flexible(maximum: 100))
    ]
    
    var body: some View {
        NavigationView {
            VStack(alignment: .trailing) {
                HStack {
                    if showingFileNameField {
                        HStack {
                            TextField("name", text: $newFileName)
                                .padding(7)
                                .border(.gray, width: 1)
//                                .textFieldStyle(.roundedBorder)
                            
                            
                            Button("OK") {
                                if !newFileName.isEmpty {
                                    withAnimation {
                                        if memos.add(fileName: newFileName) {
                                            newFileName = ""
                                        } else {
                                            showingAlreadyExist.toggle()
                                        }
                                    }
                                }
                            }
                            .frame(height: 40)
                            
                        }
                        .padding(.leading, 80)
                        .alert(isPresented: $showingAlreadyExist) {
                            Alert(title: Text("Already exists"))
                        }
                        .transition(.opacity)
                    }
                    
                    Spacer()
                    
                    //plus & minus button
                    Button(action: {
                        withAnimation {
                            showingFileNameField.toggle()
                        }
                    }){
                        if showingFileNameField {
                            Image(systemName: "minus.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.red)
                        } else {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                        }
                    }
                    .padding(.horizontal, 30)
                    
                }
                
                Divider()
                    .padding(10)
                
                ScrollView {
                    LazyVGrid(columns: layout, spacing: 20) {
                        ForEach(memos.items) { item in
                            NavigationLink(destination: SecondView(memos: memos, text: item.content, uiImage: item.uiImage, title: item.title, item: item)){
                                MemoIcon(memo: item)
                                    .transition(.opacity)
                            }
                        }
                    }
                }
                
                
            }
            .navigationTitle("Memo")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
