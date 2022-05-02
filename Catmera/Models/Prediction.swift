//
//  Prediction.swift
//  Catmera
//
//  Created by Luis Fariña on 7/5/22.
//

import SwiftUI
import Vision

struct Prediction {

    // MARK: Properties

    /// The predicted breed of the cat.
    let breed: String

    /// The confidence of the prediction, between 0 and 100.
    let confidence: Int

    /// The confidence value appending a percent sign.
    let confidencePercentage: String

    /// The color representative of the confidence value.
    let confidenceColor: Color

    // MARK: Initialization

    init(breed: String, confidence: Int) {
        self.breed = breed
        self.confidence = confidence
        confidencePercentage = "\(confidence) %"

        if confidence >= 70 {
            confidenceColor = .green
        } else if confidence >= 40 {
            confidenceColor = .yellow
        } else {
            confidenceColor = .red
        }
    }

    init(from observation: VNClassificationObservation) {
        self.init(
            breed: observation.identifier,
            confidence: Int(floor(observation.confidence * 100))
        )
    }
}
