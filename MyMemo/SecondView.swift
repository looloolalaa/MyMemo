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
    @State private var image: Image?
    @State var uiImage: UIImage?
    
    @State private var imageSacle: CGFloat = 1
    @State private var imageOffset: (width: CGFloat, height: CGFloat) = (0, 0)
    let minImageScale: CGFloat = 0.5
    let maxImageScale: CGFloat = 3
    let minImageOffset: CGFloat = -100
    let maxImageOffset: CGFloat = 100
    let backGestureThreshold: CGFloat = 50
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    // back func
    
    @State private var showingTimeOut: Bool = false
    @State private var showingProgress: Bool = false
    @State private var showingAlreadyExist: Bool = false
    @State private var showingConfirmDeleting: Bool = false
    @State private var showingImagePicker: Bool = false
    @State private var showingImageLoadFail: Bool = false
    @State private var titleFieldFocus: Bool = false
    @State private var showingDate: Bool = false
    @FocusState private var titleFieldFocused: Bool
    @FocusState private var textFieldFocused: Bool
    
    
    @State var imageLoadBlock: Bool = false
    @State var imageLoadTimeRemaining: Int = -1
    let maxImageLoadTime: Int = 5
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    
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
            .alert(isPresented: $showingTimeOut) {
                Alert(title: Text("Image loading takes too long"))
            }
            
            // loading View - activity indicator
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
                            DragGesture()
                                .onChanged { gesture in
                                    imageOffset.width += gesture.translation.width
                                    imageOffset.height += gesture.translation.height
                                    if imageOffset.width > maxImageOffset { imageOffset.width = maxImageOffset }
                                    if imageOffset.width < minImageOffset { imageOffset.width = minImageOffset }
                                    if imageOffset.height > maxImageOffset { imageOffset.height = maxImageOffset }
                                    if imageOffset.height < minImageOffset { imageOffset.height = minImageOffset }
                                }
                        )
                        .gesture(
                            MagnificationGesture()
                                .onChanged { newScale in
                                    if newScale > maxImageScale { imageSacle = maxImageScale }
                                    else if newScale < minImageScale { imageSacle = minImageScale }
                                    else { imageSacle = newScale }
                                }
                        )
                        .onTapGesture {
                            withAnimation {
                                imageSacle = 1
                                imageOffset = (0, 0)
                            }
                        }
                        .offset(x: imageOffset.width, y: imageOffset.height)
                    
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
                        
                        showingImagePicker = true
                        withAnimation {
                            showingProgress = true
                        }
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
                    .alert(isPresented: $showingImageLoadFail) {
                        Alert(title: Text("Image loading fail"))
                    }
                    
                    
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
            imageLoadTimeRemaining = -1
            
            withAnimation {
                imageSacle = 1
                imageOffset = (0, 0)
                showingProgress = false
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(uiImage: $uiImage, imageLoadBlock: $imageLoadBlock, handlers: ImagePickerHandlers(cancelAction: cancelAction, imageLoadFailAction: imageLoadFailAction, imageLoadTimerInit: imageLoadTimerInit, imageLoadTimerStart: imageLoadTimerStart, maxImageLoadTime: maxImageLoadTime))
        }
        .contentShape(Rectangle())
        
        // back func - left drag gesture
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    if gesture.translation.width > backGestureThreshold {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
        )
        
        .onReceive(timer) { _ in
            // count down
            if imageLoadTimeRemaining > 0 {
                imageLoadTimeRemaining -= 1
            }
            
            // time out
            if imageLoadTimeRemaining == 0 {
                showingTimeOut.toggle()
                imageLoadTimerInit()
                // now can load another image
                imageLoadBlock = false
                // because 5 seconds count down done
                
                withAnimation {
                    showingProgress = false
                }
            }
        }
        
    }
    
    func imageLoadTimerInit() {
        self.imageLoadTimeRemaining = -1
    }
    
    func imageLoadTimerStart() {
        self.imageLoadTimeRemaining = self.maxImageLoadTime
    }
    
    func cancelAction() {
        // someone not in loading
        if imageLoadBlock == false {
            withAnimation {
                showingProgress = false
            }
        }
    }
    
    func imageLoadFailAction() {
        imageLoadTimerInit()
        withAnimation {
            showingProgress = false
        }
        showingImageLoadFail.toggle()
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
