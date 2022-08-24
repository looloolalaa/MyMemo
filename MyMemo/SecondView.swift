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
    @State var image: Image?
    @State var uiImage: UIImage?
    
    @State private var showingConfirmDeleting: Bool = false
    @State private var showingImagePicker = false
    @FocusState private var textFieldFocused: Bool
    
    var item: Memo
    
    var body: some View {
        VStack {
            
            if let image = image {
                ZStack(alignment: .bottomTrailing) {
                    image
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(30)
                        .padding()
                    
                    Button(action: {
                        withAnimation {
                            self.image = nil
                        }
                        
                        //memos update
                        let newMemo = Memo(title: item.title, content: text, uiImage: nil, url: item.url, creationDate: item.creationDate)
                        memos.change(item: item, newItem: newMemo)
                        
                        //document delete
                        do {
                            let fileManager = FileManager()

                            //document image file delete
                            if let _  = item.uiImage {
                                let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                                let imagesURL = documentURL.appendingPathComponent("images")
                                let imageURL = imagesURL.appendingPathComponent(item.title)
                                try fileManager.removeItem(at: imageURL)
                            }

                        } catch {
                            print("Error Deleting File: \(error.localizedDescription)")
                        }
                        
                    }) {
                        Image(systemName: "x.circle.fill")
                            .foregroundStyle(.white, .red)
                    }
                    .offset(x: -15, y: -15)
                    
                }
            }
            
            TextEditor(text: $text)
                .padding()
                .frame(minHeight: 40, maxHeight: 400)
                .border(.gray)
                .focused($textFieldFocused)
                .onChange(of: text) { value in
                    do {
                        //memos update
                        let newMemo = Memo(title: item.title, content: text, uiImage: item.uiImage, url: item.url, creationDate: item.creationDate)
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
                                    //memos update
                                    memos.delete(item: item)
                                    
                                    //document text file delete
                                    let fileManager = FileManager()
                                    try fileManager.removeItem(at: item.url)
                                    
                                    //document image file delete
                                    if let _  = item.uiImage {
                                        let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                                        let imagesURL = documentURL.appendingPathComponent("images")
                                        let imageURL = imagesURL.appendingPathComponent(item.title)
                                        try fileManager.removeItem(at: imageURL)
                                    }
                    
                                } catch {
                                    print("Error Deleting File: \(error.localizedDescription)")
                                }
                          }
                    )
                }
            
            
            Button(action: {
                //dismiss key board
                textFieldFocused = false
                
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
            let newMemo = Memo(title: item.title, content: text, uiImage: uiImage, url: item.url, creationDate: item.creationDate)
            memos.change(item: item, newItem: newMemo)
            
            
            //document file write
            let fileManager = FileManager()
            let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let imagesURL = documentURL.appendingPathComponent("images")
            let imageURL = imagesURL.appendingPathComponent(item.title)
            
            let imageData = uiImage?.pngData()
            
            do {
                try imageData?.write(to: imageURL)
            } catch {
                print("Error Writing File: \(error.localizedDescription)")
            }
            
            
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
//        image = Image(uiImage: uiImage)
        withAnimation {
            image = Image(uiImage: uiImage)
        }
    }
    
}

struct SecondView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SecondView(memos: Memos(), text: Memo.example.content, image: Image("dice"), item: Memo.example)
        }
    }
}
