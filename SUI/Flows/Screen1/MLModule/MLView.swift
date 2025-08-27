//
//  MLView.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 27.08.2025.
//

import SwiftUI
import PhotosUI

struct MLView: View {
    @ObservedObject private var viewModel = MLViewModel()

    @State private var selectedImage: UIImage?
    @State private var isShowingImagePicker = false
    @State private var imageArray: [UIImage] = []

    var body: some View {
        VStack(spacing: 20) {
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .cornerRadius(12)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                    .foregroundColor(.gray)
                    .opacity(0.5)
            }
            Text(viewModel.fruitName)
                .font(.title2)
                .padding(.vertical)
            HStack(spacing: 20) {
                Button(action: {
                    isShowingImagePicker = true
                }) {
                    Label("Выбрать", systemImage: "photo")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button(action: recognizeImage) {
                    Label("Распознать", systemImage: "eye")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .disabled(selectedImage == nil)
            }
            .padding(.horizontal)
        }
        .padding()
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(selectedImage: $selectedImage, appImages: $imageArray)
        }
        .onAppear {
            Task {
                imageArray = await viewModel.createImageArray()
            }
        }
    }

    private func recognizeImage() {
        viewModel.fruitName = "Идет распознавание..."
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            viewModel.selectedImage = selectedImage
        }
    }
}
