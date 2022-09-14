//
//  TextField.swift
//  MyMemo
//
//  Created by Kihyun Lee on 2022/08/02.
//

import SwiftUI

struct SecondView: View {
    @ObservedObject var memos: Memos
    @State var title: String
    @State var text: String
    @State var uiImage: UIImage?
    @State var image: Image?
    
    
    @State private var showingAlreadyExist: Bool = false
    @State private var showingConfirmDeleting: Bool = false
    @State private var showingImagePicker: Bool = false
    @State private var titleFieldFocus: Bool = false
    @State private var showingDate: Bool = false
    @FocusState private var titleFieldFocused: Bool
    @FocusState private var textFieldFocused: Bool
    
    let item: Memo
    
    init(memos: Memos, item: Memo) {
        self.memos = memos
        self.title = item.title
        self.text = item.content
        self.uiImage = item.uiImage
        loadImage()
    }
    
    var body: some View {
        VStack {
            HStack {
                BackButton()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 10)
                
                TextField("empty", text: $title)
                    .disableAutocorrection(true)
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
                            if item.title == title {
                                titleFieldFocused = false
                            }
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
                        var newMemo = item
                        newMemo.uiImage = nil
                        
                        
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
                            
                            //document write
                            try text.write(to: item.url, atomically: false, encoding: .utf8)

                            let attr = try fileManager.attributesOfItem(atPath: item.url.path)
                            let modificationDate = attr[FileAttributeKey.modificationDate] as! Date
                            newMemo.modificationDate = modificationDate
                            memos.change(item: item, newItem: newMemo)

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
                .disableAutocorrection(true)
                .padding()
                .frame(maxHeight: 300)
                .border(.gray)
                .focused($textFieldFocused)
                .onChange(of: text) { value in
                    do {
                        //memos update
//                        let newMemo = Memo(title: item.title, content: text, uiImage: item.uiImage, url: item.url, creationDate: item.creationDate)
//                        memos.change(item: item, newItem: newMemo)
                        
                        //document write
                        try text.write(to: item.url, atomically: false, encoding: .utf8)
                        
                        let fileManager = FileManager()
                        let attr = try fileManager.attributesOfItem(atPath: item.url.path)
                        let modificationDate = attr[FileAttributeKey.modificationDate] as! Date
                        
                        var newMemo = item
                        newMemo.content = text
                        newMemo.modificationDate = modificationDate
                        memos.change(item: item, newItem: newMemo)

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
            
            ZStack(alignment: .leading) {

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
                .alert(isPresented: $showingAlreadyExist) {
                    Alert(title: Text("Already exists"))
                }
                
                .frame(maxWidth: .infinity)

                
                
                HStack {
                    Button(action: {
                        showingDate.toggle()
                    }) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.gray)
                    }
                    .padding(.leading)
                    
                    Spacer()
                }
                .padding(.leading)
                
                
            }
            .padding(.top)
//            .border(.secondary)
            
            VStack(alignment: .leading) {
                Text("created: \(item.creationDate.getString)")
                Text("modified: \(item.modificationDate.getString)")
            }
            .padding(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.caption)
            .foregroundColor(.gray)
            .opacity(showingDate ? 1 : 0)
            
            Spacer()
                
        }
        .navigationBarHidden(true)
        .onChange(of: uiImage) { _ in
            loadImage()
            
            
            //document file write
            let fileManager = FileManager()
            let documentURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let imagesURL = documentURL.appendingPathComponent("images")
            let imageURL = imagesURL.appendingPathComponent(item.title)
            
            let imageData = uiImage?.pngData()
            
            do {
                try imageData?.write(to: imageURL)
                
                //document write
                try text.write(to: item.url, atomically: false, encoding: .utf8)

                let attr = try fileManager.attributesOfItem(atPath: item.url.path)
                let modificationDate = attr[FileAttributeKey.modificationDate] as! Date
                
                var newMemo = item
                newMemo.uiImage = uiImage
                newMemo.modificationDate = modificationDate
                memos.change(item: item, newItem: newMemo)
                
            } catch {
                print("Error Writing File: \(error.localizedDescription)")
            }
            
            
            
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(uiImage: $uiImage)
        }
        
    }
    
    func loadImage() {
        guard let uiImage = uiImage else { return }
        withAnimation {
            image = Image(uiImage: uiImage)
        }
    }
    
}

struct SecondView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SecondView(memos: Memos(), item: Memo.example)
        }
    }
}
