//
//  Preferences.swift
//  Sputnik
//
//  Created by Dietrich Poensgen on 29.04.21.
//  Copyright © 2021 Peter Deal. All rights reserved.
//

import SwiftUI

struct Preferences: View {
    @State var page:String = "GeneralView"
    @State var selectedThemeIndex = UserDefaults.standard.integer(forKey: "Theme")
    
    var body: some View {
        VStack {
            // top menu bar
            ZStack {
                if #available(macOS 11.0, *) {
                    Color("white").ignoresSafeArea()
                } else {
                    Color("white")
                    
                }
                HStack(alignment: .center, spacing: 75){
                    PreferencesTab(icon: "gearshape", fallbackIcon: "􀣋", title: "General").onTapGesture {
                        self.page = "GeneralView"}
                   
                    PreferencesTab(icon: "paintbrush", fallbackIcon: "􀎑", title: "Theme").onTapGesture {
                        self.page = "ThemeView"}
                    
                    PreferencesTab(icon: "info.circle", fallbackIcon: "􀅴", title: "About").onTapGesture {
                        self.page = "AboutView"}
                   

                }
            }.frame(width: 400, height: 75)
            
            // preferences content
            VStack {
                if page == "GeneralView" {
                        Text("General").font(.headline) }
                    if page == "ThemeView" {
                        Text("Theme").font(.headline)
                        
                        // theme picker
                        Picker("Theme:", selection: $selectedThemeIndex, content: {
                                Text("Classic").tag(0)
                                Text("Dark").tag(1)
                                Text("Light").tag(2)
                                Text("Satellite").tag(3)
                        }).padding(.horizontal, 30)
                        
                        // save theme button
                        Button(action: {
                            // OUTPUT_PICKED_NUMBER: print(String(selectedThemeIndex))
                            UserDefaults.standard.set(self.selectedThemeIndex, forKey: "Theme")
                        }){
                            Text("Save")
                        }
                    }
                    if page == "AboutView" {
                        Image("Icon-64")
                        Text("Sputnik").font(.headline)
                        Text("A Gemini Browser for MacOS").font(.subheadline)
                        Text("Sputnik is a browser for MacOS that uses the Gemini Protocol, a lightweight, low-energy protocol similar to HTTPS for reading gently marked up text documents.").font(.body).padding(.horizontal)
                    }
            
            }.frame(width: 400, height: 225, alignment: .top).padding(.top)
            
        }
    }
}

struct Preferences_Previews: PreviewProvider {
    static var previews: some View {
        Preferences()
    }
}
