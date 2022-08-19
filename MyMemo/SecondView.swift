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
    
    @State var image: Image?
    @State var uiImage: UIImage?
    @State private var showingImagePicker = false
    
    var item: Memo
    
    var body: some View {
        VStack {
            image?
                .resizable()
                .scaledToFit()
                .cornerRadius(30)
                .padding()
            
            TextEditor(text: $text)
                .padding()
                .frame(minHeight: 40, maxHeight: 400)
                .border(.gray)
                .onChange(of: text) { value in
                    do {
                        //memos update
                        let newMemo = Memo(title: item.title, uiImage: uiImage, content: text, url: item.url)
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
            
            
            Button(action: {
                showingImagePicker.toggle()
            }) {
                Image(systemName: "photo")
                    .font(.title2)
                    .padding()
                    .padding(.horizontal)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(lineWidth: 1.5)
                    )
            }
            .padding()
            
            
            Spacer()
                
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(item.title)
                    .bold()
            }
            
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingConfirmDeleting.toggle()
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                
            }
        }
        .onChange(of: uiImage) { _ in
            loadImage()
            
            //memos update
            let newMemo = Memo(title: item.title, uiImage: uiImage, content: text, url: item.url)
            memos.change(item: item, newItem: newMemo)
            
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(uiImage: $uiImage)
        }
        .onAppear() {
            loadImage()
        }
        
    }
    
    func loadImage() {
        guard let uiImage = uiImage else { return }
        image = Image(uiImage: uiImage)
    }
    
}

struct SecondView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SecondView(memos: Memos(), text: Memo.example.content, image: Image("dice"), item: Memo.example)
        }
    }
}
