//
//  ViewExtension.swift
//  Catmera
//
//  Created by Luis Fariña on 13/5/22.
//

import SwiftUI

extension View {

    /// Presents an alert based on an error if it is different from nil.
    ///
    /// https://www.avanderlee.com/swiftui/error-alert-presenting
    ///
    /// - Parameters:
    ///   - error: The error to base the alert on
    func alert(error: Binding<Error?>) -> some View {
        let wrappedLocalizedError = WrappedLocalizedError(error: error.wrappedValue)

        return alert(
            isPresented: .constant(wrappedLocalizedError != nil),
            error: wrappedLocalizedError,
            actions: { _ in
                Button("OK") {
                    error.wrappedValue = nil
                }
            },
            message: { error in
                Text(error.recoverySuggestion ?? "")
            }
        )
    }
}

private struct WrappedLocalizedError: LocalizedError {

    // MARK: Properties

    private let error: LocalizedError

    // MARK: Initialization

    init?(error: Error?) {
        guard let error = error as? LocalizedError else {
            return nil
        }

        self.error = error
    }

    // MARK: LocalizedError

    var errorDescription: String? {
        error.errorDescription
    }

    var recoverySuggestion: String? {
        error.recoverySuggestion
    }
}
