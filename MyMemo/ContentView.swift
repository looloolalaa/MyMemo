//
//  ContentView.swift
//  MyMemo
//
//  Created by Kihyun Lee on 2022/07/22.
//

import SwiftUI


struct ContentView: View {
    @ObservedObject var memos: Memos
    @State private var newFileName: String = ""
    
    @State var order: Order
    
    @State private var showingFileNameField: Bool = false
    @State private var showingAlreadyExist: Bool = false
    
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
                                .disableAutocorrection(true)
                                .padding(7)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .stroke(.gray, lineWidth: 1)
                                )
                                
                            
                            
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
                    .onAppear {
                        memos.sortByOrder()
                    }
                
                HStack {
                    Picker("you pick", selection: $order.factor) {
                        ForEach(SortBy.allCases) { sortBy in
                            Text(sortBy.rawValue)
                                .foregroundStyle(.red)
                                .tag(sortBy)
                                
                        }
                    }
                    
                    Divider()
                        .onChange(of: self.order) { order in
                            memos.order = order
                            withAnimation {
                                memos.sortByOrder()
                            }
                            
                            let fileManager = FileManager()
                            let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                            let orderURL = documentURL.appendingPathComponent("order")
                            let factorURL = orderURL.appendingPathComponent("factor")
                            let reverseURL = orderURL.appendingPathComponent("reverse")
                            
                            do {
                                try (order.factor.rawValue).write(to: factorURL, atomically: false, encoding: .utf8)
                                try String(order.reverse).write(to: reverseURL, atomically: false, encoding: .utf8)
                            } catch {
                                print("Error Writing File: \(error.localizedDescription)")
                            }
                        }
                    
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
        ContentView(memos: Memos(), order: Order())
    }
}
