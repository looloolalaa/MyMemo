//
//  MemoIcon.swift
//  MyMemo
//
//  Created by Kihyun Lee on 2022/07/31.
//

import SwiftUI

struct MemoIcon: View {
    let memo: Memo
    var body: some View {
        HStack {
            VStack {
                if let uiImage = memo.uiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .frame(width: 45, height: 45)
                        .cornerRadius(10)
                } else {
                    Image(systemName: "x.square")
                        .resizable()
                        .frame(width: 45, height: 45)
                }
                Text(memo.title)
            }
            
        }
    }
}

struct MemoIcon_Previews: PreviewProvider {
    static var previews: some View {
        MemoIcon(memo: Memo.example)
    }
}
