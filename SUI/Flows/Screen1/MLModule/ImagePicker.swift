//
//  ImagePicker.swift
//  SUI
//
//  Created by Дмитрий Никоноров on 27.08.2025.
//

import SwiftUI
import PhotosUI

struct ImagePicker: View {
    @Binding var selectedImage: UIImage?
    @Binding var appImages: [UIImage]
    @Environment(\.dismiss) private var dismiss
    @State private var showLibraryPicker = false
    @State private var showAssetSelection = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Button {
                    showLibraryPicker = true
                } label: {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                        Text("Выбрать из фотоальбома")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)

                Button {
                    showAssetSelection = true
                } label: {
                    HStack {
                        Image(systemName: "folder")
                        Text("Выбрать из примеров")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)

                if showAssetSelection {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                            ForEach(appImages, id: \.self) { image in
                                Button {
                                    selectAppImage(named: image)
                                } label: {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(8)
                                        .clipped()
                                }
                            }
                        }
                        .padding()
                    }
                }
                Spacer()
            }
            .navigationTitle("Выберите изображение")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showLibraryPicker) {
                PHPickerWrapper(selectedImage: $selectedImage, dismiss: dismiss)
            }
        }
    }

    private func selectAppImage(named image: UIImage) {
        selectedImage = image
        dismiss()
    }
}

struct PHPickerWrapper: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    let dismiss: DismissAction

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> PHPickerDelegate {
        PHPickerDelegate(self, dismiss: dismiss)
    }
}

final class PHPickerDelegate: NSObject, PHPickerViewControllerDelegate {
    let parent: PHPickerWrapper
    let dismiss: DismissAction

    init(_ parent: PHPickerWrapper, dismiss: DismissAction) {
        self.parent = parent
        self.dismiss = dismiss
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss()

        guard let provider = results.first?.itemProvider else { return }

        if provider.canLoadObject(ofClass: UIImage.self) {
            provider.loadObject(ofClass: UIImage.self) { image, _ in
                DispatchQueue.main.async {
                    self.parent.selectedImage = image as? UIImage
                }
            }
        }
    }
}
