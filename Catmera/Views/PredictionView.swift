//
//  PredictionView.swift
//  Catmera
//
//  Created by Luis Fariña on 7/5/22.
//

import SwiftUI

struct PredictionView: View {

    // MARK: Properties

    let prediction: Prediction

    // MARK: Body

    var body: some View {
        HStack {
            Text(prediction.breed)
                .font(.title)
                .fontWeight(.heavy)
            Spacer()
            VStack {
                Text(prediction.confidencePercentage)
                    .font(.title)
                    .foregroundColor(prediction.confidenceColor)
                Text("Confidence")
                    .font(.footnote.smallCaps())
                    .fontWeight(.semibold)
            }
        }
    }
}

// MARK: - Previews

struct PredictionView_Previews: PreviewProvider {

    // MARK: Properties

    private static let confidenceValues = [98, 67, 36]

    // MARK: Previews

    static var previews: some View {
        ForEach(confidenceValues, id: \.self) { confidence in
            Preview {
                PredictionView(prediction: Prediction(
                    breed: "British Shorthair",
                    confidence: confidence
                ))
                    .padding()
                    .previewLayout(.sizeThatFits)
            }
        }
    }
}
