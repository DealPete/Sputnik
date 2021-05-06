//
//  ThemeData.swift
//  Sputnik
//
//  Created by Dietrich Poensgen on 30.04.21.
//  Copyright © 2021 Peter Deal. All rights reserved.
//

import SwiftUI


struct ThemeData {
    var selectedThemeIndex = UserDefaults.standard.integer(forKey: "Theme")
    
    var textColor: Color
    var linkColor: Color
    var httpLinkColor: Color
    
    var backgroundColor: Color
    
    var textFont: String
    var headingFont: String
    var linkFont: String
    var monoFont: String
    var quoteFont: String
    
    init() {
        switch (selectedThemeIndex)  {
            // classic theme
        case 0:
                textColor = Color(red: 0.85, green: 0.85, blue: 0.85)
                linkColor = .blue
                httpLinkColor = Color(red: 0, green: 0, blue: 1)
                backgroundColor = .black
                
                textFont = "Palatino"
                headingFont = "Luminari"
                linkFont = "Helvetica Neue"
                monoFont = "Courier New"
                quoteFont = "Bodoni 72"
            
            
            // dark theme
        case 1:
                textColor = .white
                linkColor = .blue
                httpLinkColor = Color(red: 0, green: 0, blue: 1)
            backgroundColor = .black
                
            textFont = "Arial"
            headingFont = "Helvetica"
            linkFont = "Helvetica Neue"
            monoFont = "Courier New"
            quoteFont = "Bodoni 72"
            
            
            // light theme
        case 2:
                textColor = .black
            linkColor = .blue
            httpLinkColor = .blue
            backgroundColor = .white
                
                textFont = "Arial"
                headingFont = "Helvetica"
                linkFont = "Helvetica Neue"
                monoFont = "Courier New"
                quoteFont = "Bodoni 72"
            
            
            // satellite theme
        case 3:
                textColor = .white
                linkColor = Color("star-yellow")
                httpLinkColor = Color("light-star-yellow")
                backgroundColor = Color("spaceblue")
                
                textFont = "Century Gothic"
                headingFont = "Impact"
                linkFont = "American Typewriter"
                monoFont = "Noto Mono for Powerline"
                quoteFont = "Bodoni 72"
            
            // classic theme for fallback
        default:
            textColor = Color(red: 0.85, green: 0.85, blue: 0.85)
            linkColor = .blue
            httpLinkColor = Color(red: 0, green: 0, blue: 1)
            backgroundColor = .black
            
            textFont = "Palatino"
            headingFont = "Luminari"
            linkFont = "Helvetica Neue"
            monoFont = "Courier New"
            quoteFont = "Bodoni 72"
        }
    }
}

