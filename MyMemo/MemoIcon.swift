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
                if let imageName = memo.image {
                    Image(imageName)
                } else {
                    Image(systemName: "x.square")
                        .resizable()
                        .frame(width: 40, height: 40)
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
