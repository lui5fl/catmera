//
//  ContentViewModel.swift
//  Catmera
//
//  Created by Luis Fariña on 4/5/22.
//

import Combine
import UIKit

@MainActor final class ContentViewModel: ObservableObject {

    // MARK: Properties

    @Published var photoPickerViewIsPresented = false
    @Published var cameraViewIsPresented = false

    /// The `Result` property to bind to the photo picker and camera views.
    @Published var result: Result<UIImage?, Error>?

    /// The error to be displayed in the view.
    @Published var error: Error?

    /// The image to be displayed in the view.
    @Published var image: UIImage?

    /// The prediction to be displayed in the view.
    @Published var prediction: Prediction?

    private var cancellables: Set<AnyCancellable> = []

    /// Publishes the result if it is different from nil.
    private lazy var resultPublisher: AnyPublisher<Result<UIImage?, Error>, Never> = {
        $result
            .compactMap {
                $0
            }
            .eraseToAnyPublisher()
    }()

    /// Publishes either a prediction or an error if the image is different from nil.
    private lazy var predictionPublisher: AnyPublisher<Result<Prediction, Error>, Never> = {
        $image
            .compactMap {
                $0
            }
            .flatMap { image in
                Predictor.makePrediction(for: image)
                    .map { prediction in
                        .success(prediction)
                    }
                    .catch { error in
                        Just(.failure(error))
                    }
            }
            .eraseToAnyPublisher()
    }()

    // MARK: Initialization

    init(subscribeToPublishers: Bool = true) {
        guard subscribeToPublishers else {
            return
        }

        subscribeToResultPublisher()
        subscribeToPredictionPublisher()
    }
}

// MARK: - Private extension

private extension ContentViewModel {

    func subscribeToResultPublisher() {
        resultPublisher
            .sink { [weak self] value in
                switch value {
                case .failure(let error):
                    self?.error = error
                case .success(let image):
                    self?.image = image
                }
            }
            .store(in: &cancellables)
    }

    func subscribeToPredictionPublisher() {
        predictionPublisher
            .sink { [weak self] value in
                switch value {
                case .failure(let error):
                    self?.error = error
                case .success(let prediction):
                    self?.prediction = prediction
                }
            }
            .store(in: &cancellables)
    }
}
