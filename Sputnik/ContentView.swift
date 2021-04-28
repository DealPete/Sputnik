//
//  ContentView.swift
//  Sputnik
//
//  Created by Peter Deal on 2020-07-08.
//  Copyright © 2020 Peter Deal. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var document: GeminiDocument
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Button( action: {
                    self.document.back()
                } )
                {if #available(OSX 11.0, *) {
                    Image(systemName: "arrow.left").imageScale(.small)
                } else {
                    Text("←")}
                
                }
                .padding(.leading, 6)
                
                Button( action: {
                    self.document.forward()
                } ) {if #available(OSX 11.0, *) {
                    Image(systemName: "arrow.right").imageScale(.small)
                } else {
                    Text("→")
                }}
                TextField("Gemini Site", text: $document.navBarUrl, onCommit: browse)
                Spacer()
            }
            
            GeminiDocumentView(document: document)
        }
    }
    
    func browse() {
        if let url = URL(string: document.navBarUrl) {
            document.navigate(url.standardized, nil)
        }
    }
}
