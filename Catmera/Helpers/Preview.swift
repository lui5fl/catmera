//
//  Preview.swift
//  Catmera
//
//  Created by Luis Fariña on 13/5/22.
//

import SwiftUI

struct Preview<Content: View>: View {

    // MARK: Properties

    let content: Content

    // MARK: Initialization

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    // MARK: Body

    var body: some View {
        Group {
            ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
                content.preferredColorScheme(colorScheme)
            }
        }
    }
}

// MARK: - Previews

struct Preview_Previews: PreviewProvider {

    static var previews: some View {
        Preview {
            Text("😸 Catmera")
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
