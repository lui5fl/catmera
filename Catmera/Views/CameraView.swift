//
//  CameraView.swift
//  Catmera
//
//  Created by Luis Fariña on 3/5/22.
//

import SwiftUI

enum CameraViewError: LocalizedError {

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

struct CameraView: UIViewControllerRepresentable {

    // MARK: Properties

    @Binding var result: Result<UIImage?, Error>?

    // MARK: UIViewControllerRepresentable

    func makeUIViewController(
        context: Context
    ) -> UIImagePickerController {
        let controller = UIImagePickerController()
        controller.delegate = context.coordinator
        controller.sourceType = .camera

        return controller
    }

    func updateUIViewController(
        _ uiViewController: UIImagePickerController,
        context: Context
    ) {
        // Do nothing
    }
}

// MARK: - Coordinator

extension CameraView {

    final class Coordinator: NSObject,
                             UIImagePickerControllerDelegate,
                             UINavigationControllerDelegate {

        // MARK: Properties

        private let parent: CameraView

        // MARK: Initialization

        init(_ parent: CameraView) {
            self.parent = parent
        }

        // MARK: UIImagePickerControllerDelegate

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            picker.dismiss(animated: true)

            guard let image = info[.originalImage] as? UIImage else {
                parent.result = .failure(CameraViewError.couldNotLoadImage)
                return
            }

            parent.result = .success(image)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
