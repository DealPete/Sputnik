//
//  SubContent.swift
//  Sputnik
//
//  Created by Peter Deal on 2020-08-30.
//  Copyright © 2020 Peter Deal. All rights reserved.
//

import SwiftUI

enum SubContent {
    case input(input: Input)
    case image(image: NSImage)
}

struct SubContentView : View {
    var subContent: SubContent?
    
    var body: some View {
        switch subContent {
        case .input(let input):
            return AnyView(InputView(input: input))
        
        case .image(let image):
            return AnyView(
                Image(nsImage: image).resizable().scaledToFit()
            )
            
        case nil:
            return AnyView(EmptyView())
        }
    }
}

struct Input {
    let text: String
    let target: GeminiURL
    let onSubmit: (GeminiURL) -> ()
}

struct InputView : View {
    @State var inputText: String = ""
    let input: Input
    
    var body: some View {
        HStack {
            Text(input.text)
            TextField("Input", text: $inputText, onCommit: {
                if !self.inputText.isEmpty {
                    let inputText = self.inputText.replacingOccurrences(of: " ", with: "%20")
                    let url = self.input.target.appendingQuery(inputText)
                    self.input.onSubmit(url)
                }
            }).frame(width: 200)
        }
    }
}
