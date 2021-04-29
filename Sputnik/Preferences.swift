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

    var body: some View {
        VStack {
            
            // top menu bar
            ZStack {
                if #available(macOS 11.0, *) {
                    Color(NSColor.white).ignoresSafeArea()
                } else {
                    Color(.white)
                    
                }
                HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 75){
                    VStack {
                        if #available(macOS 11.0, *) {
                            Image(systemName: "gearshape").imageScale(.large)
                        } else {
                            Text("􀣋").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        }
                        Text("General")
                    }.onTapGesture {
                        self.page = "GeneralView"
                    }
                    
                    VStack {
                        if #available(macOS 11.0, *) {
                            Image(systemName: "paintbrush").imageScale(.large)
                        } else {
                            Text("􀎑").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        }
                        Text("Theme")
                    }.onTapGesture {
                        self.page = "ThemeView"
                    }
                    
                    VStack {
                        if #available(macOS 11.0, *) {
                            Image(systemName: "info.circle").imageScale(.large)
                        } else {
                            Text("􀅴").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        }
                        Text("About")
                    }.onTapGesture {
                        self.page = "AboutView"
                    }

                }
            }.frame(width: 400, height: 75)
            
            // preferences content
            VStack {
                if page == "GeneralView" { Text("General") }
                    if page == "ThemeView" { Text("Theme") }
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
