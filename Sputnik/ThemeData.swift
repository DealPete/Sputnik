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
    
    init() {
       
        // classic theme
        if selectedThemeIndex == 0 {
            textColor = Color(red: 0.85, green: 0.85, blue: 0.85)
            linkColor = .blue
            httpLinkColor = Color(red: 0, green: 0, blue: 1)
            backgroundColor = .black
        }
        
        // dark theme
        if selectedThemeIndex == 1 {
            textColor = .white
            linkColor = .blue
            httpLinkColor = Color(red: 0, green: 0, blue: 1)
            backgroundColor = .black
        }
        
        // light theme
        if selectedThemeIndex == 2 {
            textColor = .black
            linkColor = .blue
            httpLinkColor = Color(red: 0, green: 0, blue: 1)
            backgroundColor = .white
        }
        
        // satellite theme
        if selectedThemeIndex == 3 {
            textColor = .white
            linkColor = Color("star-yellow")
            httpLinkColor = Color("light-star-yellow")
            backgroundColor = Color("spaceblue")
        }
        
        // at fallback use classic theme
        else {
            textColor = .white
            backgroundColor = .black
            linkColor = .blue
            httpLinkColor = Color(red: 0, green: 0, blue: 1)
        }
    }
}

