//
//  SourceView.swift
//  Sputnik
//
//  Created by Peter Deal on 2020-08-16.
//  Copyright © 2020 Peter Deal. All rights reserved.
//

import SwiftUI

struct SourceView: View {
    let content: [String]
    
    var body: some View {
        ScrollView {
            ForEach(content, id: \.self) { line in
                Text(line)
                    .font(.custom(LineView.monoFont, size: 16))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(8)
        .background(Color.black)
    }
}
