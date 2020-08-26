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
            HStack {
                Button( action: {
                    self.document.back()
                } ) {
                    Text("←")
                }
                .padding(.leading, 6)
                Button( action: {
                    self.document.forward()
                } ) {
                    Text("→")
                }
                TextField("Gemini Site", text: $document.navBarUrl, onCommit: browse)
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
