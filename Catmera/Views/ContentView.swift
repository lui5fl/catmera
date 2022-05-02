//
//  ContentView.swift
//  Catmera
//
//  Created by Luis Fariña on 2/5/22.
//

import SwiftUI

struct ContentView: View {

    // MARK: Properties

    @StateObject var viewModel = ContentViewModel()

    // MARK: Body

    var body: some View {
        VStack {
            if let prediction = viewModel.prediction,
               let image = viewModel.image {
                predictionViewWithImage(
                    prediction: prediction,
                    image: image
                )
            } else {
                placeholderView
            }
            Spacer()
            HStack(spacing: 30) {
                photoPickerButton
                cameraButton
            }
            .padding(15)
            .padding(.bottom, 30)
        }
        .fullScreenCover(isPresented: $viewModel.photoPickerViewIsPresented) {
            PhotoPickerView(result: $viewModel.result)
                .edgesIgnoringSafeArea(.all)
        }
        .fullScreenCover(isPresented: $viewModel.cameraViewIsPresented) {
            CameraView(result: $viewModel.result)
                .edgesIgnoringSafeArea(.all)
        }
        .alert(error: $viewModel.error)
    }
}

// MARK: - Private extension

private extension ContentView {

    var placeholderView: some View {
        VStack(spacing: 30) {
            Group {
                Group {
                    Text("😸 Catmera")
                    Text("Take a photo or pick one from the gallery")
                        .fontWeight(.heavy)
                }
                .font(.title)
                Text("The app will then attempt to determine the breed of the cat.")
            }
            .multilineTextAlignment(.center)
        }
        .padding(45)
        .padding(.top, 45)
    }

    var photoPickerButton: some View {
        Button {
            viewModel.photoPickerViewIsPresented = true
        } label: {
            CircleButtonLabelView(image: Image(systemName: "photo.fill.on.rectangle.fill"))
        }
    }

    var cameraButton: some View {
        Button {
            viewModel.cameraViewIsPresented = true
        } label: {
            CircleButtonLabelView(image: Image(systemName: "camera.fill"))
        }
    }

    func predictionViewWithImage(
        prediction: Prediction,
        image: UIImage
    ) -> some View {
        VStack(spacing: .zero) {
            PredictionView(prediction: prediction)
                .padding(15)
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
        }
    }
}

// MARK: - Previews

struct ContentView_Previews: PreviewProvider {

    // MARK: Properties

    private static let viewModelWithPredictionAndImage: ContentViewModel = {
        let viewModel = ContentViewModel(subscribeToPublishers: false)
        viewModel.image = UIImage(named: "Ollie")
        viewModel.prediction = Prediction(
            breed: "British Shorthair",
            confidence: 100
        )

        return viewModel
    }()

    // MARK: Previews

    static var previews: some View {
        Preview {
            ContentView()
            ContentView(viewModel: viewModelWithPredictionAndImage)
        }
    }
}
