//
//  TextField.swift
//  MyMemo
//
//  Created by Kihyun Lee on 2022/08/02.
//

import SwiftUI

struct SecondView: View {
    @ObservedObject var memos: Memos
    @State private var title: String
    @State private var text: String
    @State private var uiImage: UIImage?
    @State private var image: Image?
    @State private var showingProgress: Bool = false
    @State private var imageSacle: CGFloat = 1
    let minScale: CGFloat = 0.5
    let maxScale: CGFloat = 3
    @GestureState private var dragOffset = CGSize.zero
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    // back func
    
    @State private var showingAlreadyExist: Bool = false
    @State private var showingConfirmDeleting: Bool = false
    @State private var showingImagePicker: Bool = false
    @State private var titleFieldFocus: Bool = false
    @State private var showingDate: Bool = false
    @FocusState private var titleFieldFocused: Bool
    @FocusState private var textFieldFocused: Bool
    
    var item: Memo
    
    init(memos: Memos, item: Memo) {
        self.memos = memos
        self.item = item
        
        _title = State(initialValue: item.title)
        _text = State(initialValue: item.content)
        
        if let uiImgSrc = item.uiImage {
            _uiImage = State(initialValue: uiImgSrc)
            _image = State(initialValue: Image(uiImage: uiImgSrc))
        }
        
    }
    
    var body: some View {
        VStack {
            HStack {
                BackButton()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 10)
                
                // title field
                TextField("empty", text: $title)
                    .disableAutocorrection(true)
                    .font(.headline)
                    .padding(4)
                    .frame(width: 130)
                    .multilineTextAlignment(.center)
                    .focused($titleFieldFocused)
                    .onChange(of: titleFieldFocused) { _ in
                        withAnimation {
                            titleFieldFocus = titleFieldFocused
                        }
                    }
                    .onSubmit {
                        changeTitle()
                    }
                
                
                // title change field
                HStack {
                    // OK button
                    if titleFieldFocus {
                        
                        // title change func
                        Button("OK") {
                            changeTitle()
                        }
                    }
                    
                    Spacer()
                    
                    // red delete button
                    Button(action: {
                        showingConfirmDeleting.toggle()
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .padding(.trailing, 4)
                }
                .frame(maxWidth: .infinity)
                .padding(.trailing, 10)
                
            }
            .padding(.top, 10)
            
            if showingProgress {
                ProgressView()
                    .padding()
            }
            
            // image field
            if let image = image {
                ZStack(alignment: .bottomTrailing) {
                    image
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(30)
                        .padding([.leading, .bottom, .trailing])
                        .scaleEffect(imageSacle)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { newScale in
                                    if newScale > maxScale { imageSacle = maxScale }
                                    else if newScale < minScale { imageSacle = minScale }
                                    else { imageSacle = newScale }
                                }
                        )
                        .onTapGesture {
                            withAnimation {
                                imageSacle = 1
                            }
                        }
                    
                    // image X button
                    Button(action: {
                        self.uiImage = nil
                    }) {
                        Image(systemName: "x.circle.fill")
                            .foregroundStyle(.white, .red)
                    }
                    .offset(x: -15, y: -15)
                    
                }
                
            }
            
            // text field
            TextEditor(text: $text)
                .disableAutocorrection(true)
                .padding()
                .frame(maxHeight: 300)
                .border(.gray)
                .focused($textFieldFocused)
                .onChange(of: self.text) { _ in
                    memos.changeContent(item: item, newContent: self.text)
                }
                //delete button
                .alert(isPresented: $showingConfirmDeleting) {
                    Alert(title: Text("Are you sure?"),
                          primaryButton: .cancel(),
                          secondaryButton: .destructive(Text("Delete")) {
                                memos.delete(item: item)
                          }
                    )
                }
            
            VStack {
                // date & image button
                ZStack(alignment: .leading) {

                    // image plus button
                    Button(action: {
                        // dismiss key board
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

                    
                    // date info button
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
            
                
                // date info
                VStack(alignment: .leading) {
                    Text("created: \(item.creationDate.getString)")
                    Text("modified: \(item.modificationDate.getString)")
                }
                .padding(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.caption)
                .foregroundColor(.gray)
                .opacity(showingDate ? 1 : 0)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                hideKeyboard()
            }
            
            Spacer()
                
        }
        .navigationBarHidden(true)
        .onChange(of: self.uiImage) { _ in
            loadImage()
            memos.changeUIImage(item: item, newUIImage: self.uiImage)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(uiImage: $uiImage)
        }
        .contentShape(Rectangle())
        
        // back func - left drag gesture
        .gesture(DragGesture().updating($dragOffset) { (value, state, transaction) in
            if value.translation.width > 80 {
                presentationMode.wrappedValue.dismiss()
            }
        })
        .onChange(of: showingImagePicker) { _ in
            withAnimation {
                showingProgress = showingImagePicker
            }
        }
        
    }
    
    // enter key action
    func changeTitle() {
        // no change
        if item.title == title {
            titleFieldFocused = false
            
        } else if !title.isEmpty {
            
            // already exist
            if memos.fileExists(newFileName: self.title) {
                
                titleFieldFocused = true
                showingAlreadyExist.toggle()
                
            } else {
                // title change
                memos.changeTitle(item: item, newTitle: self.title)
                
                titleFieldFocused = false
            }
        }
    }
    
    // UIImage -> Image
    func loadImage() {
        guard let uiImage = uiImage else {
            withAnimation {
                image = nil
            }
            return
        }
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
