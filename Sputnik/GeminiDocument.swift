//
//  GeminiDocument.swift
//  Sputnik
//
//  Created by Peter Deal on 2020-07-11.
//  Copyright © 2020 Peter Deal. All rights reserved.
//

import SwiftUI

struct GeminiDocumentView: View {
    @ObservedObject var document: GeminiDocument
    
    var body: some View {
        ScrollView {
            if document.ready {
                ForEach(document.lines, id: \.self.id) { line in
                    LineView(line, onClick: self.document.navigate, onSubmit: self.document.connect)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(8)
        .background(Color.black)
    }
}

class GeminiDocument: ObservableObject {
    @Published var lines: [Line] = []
    @Published var ready: Bool = false
    @Published var navBarUrl: String
    var rawText: [String] = []
    var navStack: [GeminiURL]
    var navIndex = 0

    init() {
        let url = GeminiURL()
        navBarUrl = url.toString()
        navStack = [url]
        self.connect()
    }
    
    func connect(target: GeminiURL? = nil, lineId: Int? = nil) {
        let url = target ?? navStack[navIndex]
        var connection: NetworkCall
        connection = NetworkCall(url: url)
        
        connection.activate() { result in
            switch result {
            case .success(text: let text, mimeType: let mimeType):
                self.navBarUrl = url.toString()
                
                if let target = target {
                    self.navIndex += 1
                    self.navStack.replaceSubrange(self.navIndex..<self.navStack.count, with: [target])
                }
                
                let textLines = toLines(text)
                self.rawText = textLines
                
                switch mimeType {
                case .textPlain:
                    var lines: [Line] = []
                    for (index, line) in textLines.enumerated() {
                        lines.append( Line(text: line, type: .preformat, id: index) )
                    }
                    self.lines = lines
                
                case .textGemini:
                    self.lines = self.parse(text: textLines)
                }
                
                self.ready = false
                // give SwiftUI a moment to destroy the ScrollView, otherwise the new
                // page will be scrolled to the same height as the old page.
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.ready = true
                }

            case .input(let text):
                let lineId = lineId!
                
                let inputLineId = lineId + 1
                let inputLine = Line(text: text, type: .input(target: url), id: inputLineId)

                if let index = self.lines.firstIndex(where: { $0.id == inputLineId } ) {
                    self.lines[index] = inputLine
                } else if let index = self.lines.firstIndex(where: { $0.id == lineId } ) {
                    self.lines.insert(inputLine, at: index + 1)
                }

            case .redirect(let url):
                print("Redirected to \(url)")
                self.connect(target: url)
                
            case .error(let text):
                guard let lineId = lineId else {
                    print("Error: ", text)
                    return
                }
                
                let errorLineId = lineId + 2
                let errorLine = Line(text: text, type: .error, id: errorLineId)

                if let index = self.lines.firstIndex(where: { $0.id == errorLineId } ) {
                    self.lines[index] = errorLine
                } else if let index = self.lines.firstIndex(where: { $0.id == lineId } ) {
                    self.lines.insert(errorLine, at: index + 1)
                }
            }
        }
    }
    
    func navigate(_ target: URL, _ lineId: Int?) {
        var newUrl: GeminiURL
        
        if target.host != nil {
            newUrl = GeminiURL(url: target)
        } else {
            let oldUrl = navStack[navIndex]
            newUrl = oldUrl.combiningRelative(url: target)
        }

        self.connect(target: newUrl, lineId: lineId)
    }
    
    func back() {
        if navIndex > 0 {
            navIndex -= 1
        }
        
        self.connect()
    }
    
    func forward() {
        if navIndex < navStack.count - 1 {
            navIndex += 1
        }
        
        self.connect()
    }
    
    func parse(text: [String]) -> [Line] {
        enum State {
            case preformat
            case regular
        }
        
        var lines: [Line] = []
        var state = State.regular
        var id = 0
        
        for line in text {
            switch state {
            case .regular:
                if line.hasPrefix("```") {
                    state = .preformat
                } else {
                    lines.append(Line.create(from: line, id: id))
                }
            
            case .preformat:
                if line.hasPrefix("```") {
                    state = .regular
                } else {
                    lines.append(Line(text: line, type: .preformat, id: id))
                }
            }
            
            id += 3
        }
        
        return lines
    }
}

func toLines(_ text: String) -> [String] {
    var lines: [String] = []
    var line = ""
    
    for char in text {
        if char.isNewline {
            if char.asciiValue != 0x0d {
                lines.append(line)
                line = ""
            }
        } else {
            line.append(char)
        }
    }
    
    if !line.isEmpty {
        lines.append(line)
    }
    
    return lines
}
