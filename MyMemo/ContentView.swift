//
//  ContentView.swift
//  MyMemo
//
//  Created by Kihyun Lee on 2022/07/22.
//

import SwiftUI


struct ContentView: View {
    @ObservedObject var memos: Memos
    @State private var order: Order
    
    @State private var newFileName: String = ""
    @FocusState private var newFileNameFocused: Bool
    @State private var showingFileNameField: Bool = false
    @State private var showingAlreadyExist: Bool = false
    
    let layout = [
        GridItem(.flexible(maximum: 100)),
        GridItem(.flexible(maximum: 100)),
        GridItem(.flexible(maximum: 100))
    ]
    
    init(memos: Memos) {
        self.memos = memos
        self.order = memos.order
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .trailing) {
                HStack {
                    
                    // file name field
                    HStack {
                        TextField("name", text: $newFileName)
                            .disableAutocorrection(true)
                            .padding(7)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(.gray, lineWidth: 1)
                            )
                            .focused($newFileNameFocused)
                            
                        
                        
                        Button("OK") {
                            if !newFileName.isEmpty {
                                withAnimation {
                                    // not exist
                                    if !memos.fileExists(newFileName: newFileName) {
                                        memos.appendNewMemo(newFileName: newFileName)
                                        newFileName = ""
                                    } else {
                                        // already exist
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
                    .opacity(showingFileNameField ? 1 : 0)

                    
                    Spacer()
                    
                    //plus & minus button
                    Button(action: {
                        withAnimation {
                            showingFileNameField.toggle()
                        }
                        
                        if showingFileNameField {
                            newFileNameFocused = true
                        } else {
                            newFileNameFocused = false
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
                
                // order field
                HStack {
                    // picker
                    Picker("you pick", selection: $order.factor) {
                        ForEach(SortBy.allCases) { sortBy in
                            Text(sortBy.rawValue)
                                .foregroundStyle(.red)
                                .tag(sortBy)
                                
                        }
                    }
                    
                    Divider()
                        .onChange(of: self.order) { _ in
                            memos.order = self.order
                        }
                    
                    // arrow reverse
                    Button(action: {
                        order.reverse.toggle()
                    }) {
                        if order.reverse {
                            Image(systemName: "arrow.up")
                        } else {
                            Image(systemName: "arrow.down")
                        }
                    }
                }
                .frame(height: 20)
                .padding([.horizontal, .bottom])
                
                // main scroll grid
                ScrollView {
                    LazyVGrid(columns: layout, spacing: 20) {
                        ForEach(memos.items) { item in
                            NavigationLink(destination: SecondView(memos: memos, item: item)){
                                MemoIcon(memo: item)
                                    .transition(.opacity)
                            }
                        }
                    }
                }
                .onTapGesture {
                    hideKeyboard()
                }
                
                
            }
            .navigationTitle("Memo")
        }
        .navigationViewStyle(.stack)
        // remove warning
    }
}

func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(memos: Memos())
    }
}
