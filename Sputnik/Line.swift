//
//  Line.swift
//  Sputnik
//
//  Created by Peter Deal on 2020-08-01.
//  Copyright © 2020 Peter Deal. All rights reserved.
//

import Foundation
import SwiftUI

struct Line {
    var text: String
    var type: LineType
    let id: Int
    
    static func create(from: String, id: Int) -> Line {
        if from.hasPrefix("=>") {
            var text = ""
            var url = ""
            
            enum ParserState {
                case prefix
                case url
                case text
            }
            
            var state = ParserState.prefix
            
            for (index, char) in from.enumerated() {
                if index < 2 {
                    continue
                }
                
                switch state {
                case .prefix:
                    if char.isWhitespace {
                        continue
                    }
                    
                    url.append(char)
                    state = .url
                
                case .url:
                    if char.isWhitespace {
                        state = .text
                    } else {
                        url.append(char)
                    }
                
                case .text:
                    if text == "" && char.isWhitespace {
                        continue
                    }
                    
                    text.append(char)
                }
            }
            
            if state == .prefix {
                return error("No URL given for link.", id: id)
            }
            
            guard let URL = URL(string: url) else {
                return error("Link has invalid URL.", id: id)
            }
            
            if text == "" {
                return Line(text: url, type: .link(target: URL.standardized), id: id)
            } else {
                return Line(text: text, type: .link(target: URL.standardized), id: id)
            }
        }
        
        if from.hasPrefix("###") {
            let text = from.drop(while: { $0 == "#" })
            return Line(text: text.trimmingCharacters(in: .whitespaces), type: .heading3, id: id)
        }
        
        if from.hasPrefix("##") {
            let text = from.drop(while: { $0 == "#" })
            return Line(text: text.trimmingCharacters(in: .whitespaces), type: .heading2, id: id)
        }
        
        if from.hasPrefix("#") {
            let text = from.drop(while: { $0 == "#" })
            return Line(text: text.trimmingCharacters(in: .whitespaces), type: .heading1, id: id)
        }

        if from.hasPrefix("*") {
            let text = from.drop(while: { $0 == "*" })
            return Line(text: text.trimmingCharacters(in: .whitespaces), type: .list, id: id)
        }
        
        if from.hasPrefix(">") {
            let text = from.drop(while: { $0 == ">" })
             return Line(text: text.trimmingCharacters(in: .whitespaces), type: .quote, id: id)
        }
        
        return Line(text: from, type: .text, id: id)
    }

    static func error(_ error: String, id: Int) -> Line {
        return Line(text: error, type: .error, id: id)
    }
}

struct LineView: View {
    @State var input: String = ""
    var line: Line
    var background: Color = .black
    let textFont = "Palatino"
    let headingFont = "Luminari"
    let linkFont = "Helvetica Neue"
    static let monoFont = "Courier New"
    let quoteFont = "Bodoni 72"
    let onClick: (URL, Int) -> ()
    let onSubmit: (GeminiURL, Int) -> ()
    
    init(_ line: Line, onClick: @escaping (URL, Int) -> (), onSubmit: @escaping (GeminiURL, Int) -> ()) {
        self.line = line
        self.onClick = onClick
        self.onSubmit = onSubmit
    }
    
    var body: some View {
        let text = Text(line.text)
        var view: AnyView
        var background: Color = .black
        var padding = 6.0
        
        switch line.type {
        case .heading1:
            view = AnyView(text.font(.custom(headingFont, size: 30)).foregroundColor(.white))
        case .heading2:
            view = AnyView(text.font(.custom(headingFont, size: 25)).foregroundColor(.white))
        case .heading3:
            view = AnyView(text.font(.custom(headingFont, size: 20)).foregroundColor(.white))
        
        case .quote:
            let endQuote = line.text.isEmpty ? "" : "”"
            let startQuote = line.text.isEmpty ? "" : "“"
            view = AnyView(Text(startQuote + line.text + endQuote).font(.custom(quoteFont, size: 18)).foregroundColor(.green))
            
        case .list:
            view = AnyView(Text("• " + line.text).font(.custom(textFont, size: 16)).lineSpacing(6))
            
        case .link(let target):
            view = AnyView(Button(action: {
                if target.scheme == "http" || target.scheme == "https" {
                    NSWorkspace.shared.open(target)
                } else {
                    self.onClick(target, self.line.id)
                }
            }) {
                text.font(.custom(linkFont, size: 16))
                    .foregroundColor(target.scheme == "http" || target.scheme == "https" ?
                        Color(red: 0, green: 0, blue: 1) : .blue)
            }.buttonStyle(PlainButtonStyle()))
        
        case .input(let target):
            view = AnyView(
                HStack {
                    TextField("Input", text: $input, onCommit: {
                        if !self.input.isEmpty {
                            let inputText = self.input.replacingOccurrences(of: " ", with: "%20")
                            let url = target.appendingQuery(inputText)
                            self.onSubmit(url, self.line.id)
                        }
                    }).frame(width: 200)
                    Text(line.text)
            })
            
        case .preformat:
            view = AnyView(text.font(.custom(LineView.monoFont, size: 16)).foregroundColor(.yellow))
            padding = 0
            
        case .error:
            background = .red
            view = AnyView(text)
        
        case .text:
            view = AnyView(text.font(.custom(textFont, size: 16)).lineSpacing(6))
        }
        
        return view
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, CGFloat(padding))
            .background(background)
    }
}

enum LineType {
    case text
    case heading1
    case heading2
    case heading3
    case quote
    case list
    case link(target: URL)
    case input(target: GeminiURL)
    case preformat
    case error
}
