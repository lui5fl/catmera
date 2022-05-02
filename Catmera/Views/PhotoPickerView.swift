//
//  PhotoPickerView.swift
//  Catmera
//
//  Created by Luis Fariña on 3/5/22.
//

import PhotosUI
import SwiftUI

enum PhotoPickerViewError: LocalizedError {

    // MARK: Cases

    case couldNotLoadImage

    // MARK: LocalizedError

    var errorDescription: String? {
        let errorDescription: String
        switch self {
        case .couldNotLoadImage:
            errorDescription = NSLocalizedString("Could not load image", comment: "")
        }

        return errorDescription
    }

    var recoverySuggestion: String? {
        let recoverySuggestion: String
        switch self {
        case .couldNotLoadImage:
            recoverySuggestion = NSLocalizedString("Try again with another one.", comment: "")
        }

        return recoverySuggestion
    }
}

struct PhotoPickerView: UIViewControllerRepresentable {

    // MARK: Properties

    @Binding var result: Result<UIImage?, Error>?

    // MARK: UIViewControllerRepresentable

    func makeUIViewController(
        context: Context
    ) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images

        let controller = PHPickerViewController(configuration: configuration)
        controller.delegate = context.coordinator

        return controller
    }

    func updateUIViewController(
        _ uiViewController: PHPickerViewController,
        context: Context
    ) {
        // Do nothing
    }
}

// MARK: - Coordinator

extension PhotoPickerView {

    final class Coordinator: PHPickerViewControllerDelegate {

        // MARK: Properties

        private let parent: PhotoPickerView

        // MARK: Initialization

        init(_ parent: PhotoPickerView) {
            self.parent = parent
        }

        // MARK: PHPickerViewControllerDelegate

        func picker(
            _ picker: PHPickerViewController,
            didFinishPicking results: [PHPickerResult]
        ) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider else {
                parent.result = .success(nil)
                return
            }

            guard provider.canLoadObject(ofClass: UIImage.self) else {
                parent.result = .failure(PhotoPickerViewError.couldNotLoadImage)
                return
            }

            provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                DispatchQueue.main.async {
                    guard
                        error == nil,
                        let image = image as? UIImage
                    else {
                        self?.parent.result = .failure(PhotoPickerViewError.couldNotLoadImage)
                        return
                    }

                    self?.parent.result = .success(image)
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
