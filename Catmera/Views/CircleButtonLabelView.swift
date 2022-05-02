//
//  CircleButtonLabelView.swift
//  Catmera
//
//  Created by Luis Fariña on 7/5/22.
//

import SwiftUI

struct CircleButtonLabelView: View {

    // MARK: Properties

    let image: Image

    // MARK: Body
    
    var body: some View {
        image
            .foregroundColor(.white)
            .frame(width: 50, height: 50)
            .background(.gray.opacity(0.75), in: Circle())
    }
}

// MARK: - Previews

struct CircleButtonLabelView_Previews: PreviewProvider {

    // MARK: Properties

    private static let colors: [Color] = [
        .black,
        .blue,
        .green,
        .red,
        .white
    ]

    // MARK: Previews

    static var previews: some View {
        Group {
            ForEach(colors, id: \.self) { color in
                CircleButtonLabelView(image: Image(systemName: "camera.fill"))
                    .padding()
                    .background(color)
            }
        }
        .previewLayout(.sizeThatFits)
    }
}
