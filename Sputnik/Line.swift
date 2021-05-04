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
    
    static func create(from: String) throws -> Line {
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
                throw LineParsingError(message: "No URL given for link.")
            }
            
            guard let URL = URL(string: url) else {
                throw LineParsingError(message: "Link has invalid URL.")
            }
            
            if text == "" {
                return Line(text: url, type: .link(target: URL))
            } else {
                return Line(text: text, type: .link(target: URL))
            }
        }
        
        if from.hasPrefix("###") {
            let text = from.drop(while: { $0 == "#" })
            return Line(text: text.trimmingCharacters(in: .whitespaces), type: .heading3)
        }
        
        if from.hasPrefix("##") {
            let text = from.drop(while: { $0 == "#" })
            return Line(text: text.trimmingCharacters(in: .whitespaces), type: .heading2)
        }
        
        if from.hasPrefix("#") {
            let text = from.drop(while: { $0 == "#" })
            return Line(text: text.trimmingCharacters(in: .whitespaces), type: .heading1)
        }

        if from.hasPrefix("*") {
            let text = from.drop(while: { $0 == "*" })
            return Line(text: text.trimmingCharacters(in: .whitespaces), type: .list)
        }
        
        if from.hasPrefix(">") {
            let text = from.drop(while: { $0 == ">" })
             return Line(text: text.trimmingCharacters(in: .whitespaces), type: .quote)
        }
        
        return Line(text: from, type: .text)
    }
}

struct LineView: View {
    var line: Line?
    var background: Color = ThemeData().backgroundColor
    let textColor: Color = ThemeData().textColor
    let textFont = "Palatino"
    let headingFont = "Luminari"
    let linkFont = "Helvetica Neue"
    static let monoFont = "Courier New"
    let quoteFont = "Bodoni 72"
    let onClick: (URL) -> ()
    
    init(_ line: Line?, onClick: @escaping (URL) -> ()) {
        self.line = line
        self.onClick = onClick
    }
    
    var body: some View {
        guard let line = self.line else {
            return AnyView(EmptyView())
        }

        let text = Text(line.text)
        var view: AnyView
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
            view = AnyView(Text("• " + line.text).font(.custom(textFont, size: 16)).foregroundColor(textColor).lineSpacing(6))
            
        case .link(let target):
            view = AnyView(Button(action: {
                if target.scheme == "http" || target.scheme == "https" {
                    NSWorkspace.shared.open(target)
                } else {
                    self.onClick(target)
                }
            }) {
                text.font(.custom(linkFont, size: 16))
                    .foregroundColor(target.scheme == "http" || target.scheme == "https" ?
                                        ThemeData().httpLinkColor : ThemeData().linkColor)
            }.buttonStyle(PlainButtonStyle()))
            
        case .preformat:
            view = AnyView(text.font(.custom(LineView.monoFont, size: 16)).foregroundColor(.yellow))
            padding = 0
        
        case .text:
            view = AnyView(text.font(.custom(textFont, size: 16)).foregroundColor(textColor).lineSpacing(6))
        }
        
        return AnyView(view
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, CGFloat(padding)))
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
    case preformat
}

struct LineParsingError : Error {
    let message: String
}
