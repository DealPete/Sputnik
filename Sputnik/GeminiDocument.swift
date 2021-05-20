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
                ForEach(document.nodes, id: \.self.id) { node in
                    VStack {
                        LineView(node.content, onClick: { url in
                            self.document.navigate(url, node.id)
                        })
                        SubContentView(subContent: node.subContent)
                        ErrorView(error: node.error)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(8)
        .background(ThemeData().backgroundColor)
    }
}

struct ErrorView: View {
    let error: String?

    var body: some View {
        if let error = error {
            return AnyView(Text(error).background(Color.red))
        } else {
            return AnyView(EmptyView())
        }
    }
}

class GeminiDocument: ObservableObject {
    @Published var nodes: [Node] = []
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
            case .success(documentBytes: let bytes, mimeType: let mimeType):
                
                switch mimeType {
                case .text(charset: let charset, format: let format):
                    guard let text = String(data: bytes, encoding: charset) else {
                        self.error(text: "Document is not valid \(charset).", lineId: lineId)
                        return
                    }
                    self.navBarUrl = url.toString()
                    
                    if let target = target {
                        self.navIndex += 1
                        self.navStack.replaceSubrange(self.navIndex..<self.navStack.count, with: [target])
                    }
                
                    let textLines = toLines(text)
                    self.rawText = textLines
                
                    switch format {
                    case .plain:
                        var nodes: [Node] = []
                        for line in textLines {
                            nodes.append( Node(Line(text: line, type: .preformat)) )
                        }
                        self.nodes = nodes
                    
                    case .gemini:
                        self.nodes = self.parse(text: textLines)
                    }
                
                    self.ready = false
                    // give SwiftUI a moment to destroy the ScrollView, otherwise the new
                    // page will be scrolled to the same height as the old page.
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        self.ready = true
                    }
                
                case .image:
                    if let lineId = lineId {
                        if let image = NSImage(data: bytes) {
                            self.add(subContent: .image(image: image), toNodeWith: lineId)
                        }
                    } else {
                        // code for opening image from address bar
                    }
                }

            case .input(let text):
                if let lineId = lineId {
                    let input = Input(text: text, target: url, onSubmit: { url in
                        self.connect(target: url, lineId: lineId)
                    })
                    
                    self.add(subContent: .input(input: input), toNodeWith: lineId)
                }

            case .redirect(let url):
                print("Redirected to \(url)")
                self.connect(target: url)
                
            case .error(let text):
                self.error(text: text, lineId: lineId)
            }
        }
    }
    
    func navigate(_ target: URL, _ lineId: Int?) {
        var newUrl: GeminiURL
        
        if target.host != nil {
            newUrl = GeminiURL(url: target)
        } else {
            let oldUrl = navStack[navIndex]
            newUrl = oldUrl.combiningRelative(url: target.standardized.absoluteURL)
        }

        self.connect(target: newUrl, lineId: lineId)
    }
    
    func back() {
        if navIndex > 0 {
            navIndex -= 1
            self.connect()
        }
    }
    
    func forward() {
        if navIndex < navStack.count - 1 {
            navIndex += 1
            self.connect()
        }
    }
    
    func parse(text: [String]) -> [Node] {
        enum State {
            case preformat
            case regular
        }
        
        var nodes: [Node] = []
        var state = State.regular
        
        for line in text {
            switch state {
            case .regular:
                if line.hasPrefix("```") {
                    state = .preformat
                } else {
                    do {
                        nodes.append(Node(try Line.create(from: line)))
                    } catch let error as LineParsingError {
                        nodes.append(Node(nil, nil, error.message))
                    } catch {
                        ()
                    }
                }
            
            case .preformat:
                if line.hasPrefix("```") {
                    state = .regular
                } else {
                    nodes.append(Node(Line(text: line, type: .preformat)))
                }
            }
        }
        
        return nodes
    }
    
    func error(text: String, lineId: Int?) {
        guard let lineId = lineId else {
            print("Error: ", text)
            return
        }
        
        if let index = self.nodes.firstIndex(where: { $0.id == lineId }) {
            let node = nodes[index]
            nodes[index] = Node(node.content, node.subContent, text)
        }
    }
    
    func add(subContent: SubContent, toNodeWith lineId: Int) {
        if let index = self.nodes.firstIndex(where: { $0.id == lineId }) {
            let node = nodes[index]
            nodes[index] = Node(node.content, subContent, node.error)
        }
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

struct Node {
    static var nextId: Int = 0
    let id: Int
    let content: Line?
    var subContent: SubContent?
    var error: String?
    
    init(_ content: Line?, _ subContent: SubContent? = nil, _ error: String? = nil) {
        self.content = content
        self.subContent = subContent
        self.error = error
        Node.nextId += 1
        self.id = Node.nextId
    }
}
