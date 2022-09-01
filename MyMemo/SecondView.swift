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
    @State var title: String
    
    @State private var showingAlreadyExist = false
    @State private var showingConfirmDeleting: Bool = false
    @State private var showingImagePicker: Bool = false
    @State private var titleFieldFocus: Bool = false
    @FocusState private var titleFieldFocused: Bool
    @FocusState private var textFieldFocused: Bool
    
    var item: Memo
    
    var body: some View {
        VStack {
            HStack {
                BackButton()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 10)
                
                TextField("empty", text: $title)
                    .font(.headline)
                    .padding(4)
                    .frame(width: 130)
                    .multilineTextAlignment(.center)
                    .focused($titleFieldFocused)
                    .onChange(of: titleFieldFocused) { focus in
                        withAnimation {
                            titleFieldFocus = focus
                        }
                    }
                
                
                HStack {
                    if titleFieldFocus {
                        Button("OK") {
                            if !title.isEmpty && item.title != title {
                                let fileManager = FileManager()
                                let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                                let textsURL = documentURL.appendingPathComponent("texts")
                                let newTextURL = textsURL.appendingPathComponent(title)
                                
                                if fileManager.fileExists(atPath: newTextURL.path) {
                                    titleFieldFocused = true
                                    showingAlreadyExist.toggle()
                                    
                                } else {
                                    //memos update
                                    var newMemo = item
                                    newMemo.title = title
                                    memos.change(item: item, newItem: newMemo)
                                    
                                    //document delete
                                    do {
                                        let textURL = textsURL.appendingPathComponent(item.title)
                                        try fileManager.moveItem(at: textURL, to: newTextURL)
                                        
                                        //document image file delete
                                        if let _  = item.uiImage {
                                            let imagesURL = documentURL.appendingPathComponent("images")
                                            
                                            let imageURL = imagesURL.appendingPathComponent(item.title)
                                            let newImageURL = imagesURL.appendingPathComponent(title)
                                            
                                            try fileManager.moveItem(at: imageURL, to: newImageURL)
                                        }

                                    } catch {
                                        print("Error Moving File: \(error.localizedDescription)")
                                    }
                                    
                                    titleFieldFocused = false
                                }
                            }
                            
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showingConfirmDeleting.toggle()
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.trailing, 10)
                
            }
            .padding(.top, 10)
            
            if let image = image {
                ZStack(alignment: .bottomTrailing) {
                    image
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(30)
                        .padding([.leading, .bottom, .trailing])
                    
                    //image X button
                    Button(action: {
                        withAnimation {
                            self.image = nil
                        }
                        
                        //memos update
//                        let newMemo = Memo(title: item.title, content: text, uiImage: nil, url: item.url, creationDate: item.creationDate)
//                        memos.change(item: item, newItem: newMemo)
                        
                        var newMemo = item
                        newMemo.uiImage = nil
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
//                        let newMemo = Memo(title: item.title, content: text, uiImage: item.uiImage, url: item.url, creationDate: item.creationDate)
//                        memos.change(item: item, newItem: newMemo)
                        
                        var newMemo = item
                        newMemo.content = text
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
            
            //image plus button
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
            .alert(isPresented: $showingAlreadyExist) {
                Alert(title: Text("Already exists"))
            }
            
            
            Spacer()
                
        }
        .navigationBarHidden(true)
        .onChange(of: uiImage) { _ in
            loadImage()
            
            //memos update
//            let newMemo = Memo(title: item.title, content: text, uiImage: uiImage, url: item.url, creationDate: item.creationDate)
//            memos.change(item: item, newItem: newMemo)
            
            var newMemo = item
            newMemo.uiImage = uiImage
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
            SecondView(memos: Memos(), text: Memo.example.content, image: Image("dice"), title: "hello", item: Memo.example)
        }
    }
}
