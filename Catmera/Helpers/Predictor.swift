//
//  Predictor.swift
//  Catmera
//
//  Created by Luis Fariña on 7/5/22.
//

import Combine
import UIKit
import Vision

enum PredictorError: LocalizedError {

    // MARK: Cases

    case couldNotMakePrediction
    case invalidImage
    case predictionFailed

    // MARK: LocalizedError

    var errorDescription: String? {
        let errorDescription: String
        switch self {
        case .couldNotMakePrediction:
            errorDescription = NSLocalizedString("Could not make prediction", comment: "")
        case .invalidImage:
            errorDescription = NSLocalizedString("Invalid image", comment: "")
        case .predictionFailed:
            errorDescription = NSLocalizedString("Prediction failed", comment: "")
        }
        
        return errorDescription
    }

    var recoverySuggestion: String? {
        let recoverySuggestion: String
        switch self {
        case .couldNotMakePrediction, .predictionFailed:
            recoverySuggestion = NSLocalizedString("Try again with another image.", comment: "")
        case .invalidImage:
            recoverySuggestion = NSLocalizedString("Try again with another one.", comment: "")
        }

        return recoverySuggestion
    }
}

final class Predictor {

    // MARK: Properties

    private static let model: VNCoreMLModel = {
        guard
            let classifier = try? CatClassifier(configuration: MLModelConfiguration()),
            let model = try? VNCoreMLModel(for: classifier.model)
        else {
            fatalError("Failed to initialize the machine learning model.")
        }

        return model
    }()

    // MARK: Methods

    /// Returns a publisher that, after making an image classification request to the machine
    /// learning model, eventually resolves either to a prediction or an error.
    ///
    /// - Parameters:
    ///   - image: The image to be used for the request
    class func makePrediction(
        for image: UIImage
    ) -> AnyPublisher<Prediction, PredictorError> {

        Future<Prediction, PredictorError> { promise in
            guard let cgImage = image.cgImage else {
                promise(.failure(.invalidImage))
                return
            }

            let request = VNCoreMLRequest(model: model) { request, error in
                guard error == nil else {
                    promise(.failure(.predictionFailed))
                    return
                }

                guard let observation = request.results?.first as? VNClassificationObservation else {
                    promise(.failure(.couldNotMakePrediction))
                    return
                }

                promise(.success(Prediction(from: observation)))
            }
            request.imageCropAndScaleOption = .centerCrop

            do {
                try VNImageRequestHandler(
                    cgImage: cgImage,
                    orientation: CGImagePropertyOrientation(image.imageOrientation)
                ).perform([request])
            } catch {
                promise(.failure(.predictionFailed))
            }
        }
        .eraseToAnyPublisher()
    }
}
