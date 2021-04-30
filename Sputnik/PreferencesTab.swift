//
//  PreferencesTab.swift
//  Sputnik
//
//  Created by Dietrich Poensgen on 29.04.21.
//  Copyright © 2021 Peter Deal. All rights reserved.
//

import SwiftUI

struct PreferencesTab: View {
    var icon: String
    var fallbackIcon: String
    var title: String
    
    @State private var hovered : Bool = false
    
    var body: some View {
        VStack {
            if #available(macOS 11.0, *) {
                Image(systemName: icon).imageScale(.large).padding(.top, 5)
            } else {
                Text(fallbackIcon).font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/).padding(.top, 5)
            }
            Text(title).padding([.horizontal, .bottom],5)
        }.onHover(perform: { hovering in
            self.hovered = hovering
        }).background(RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hovered ? "coolGray" : "white")))
    }
}

struct PreferencesTab_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesTab(icon: "", fallbackIcon: "", title: "")
    }
}
