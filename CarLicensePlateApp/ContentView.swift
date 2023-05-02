//
//  ContentView.swift
//  CarLicensePlateApp
//
//  Created by Илья Малахов on 02.05.2023.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @ObservedObject private var viewModel = ClassifierViewModel()
    
    var body: some View {
        VStack {
            PhotosPicker(
                selection: $selectedItem,
                matching: .images,
                photoLibrary: .shared()) {
                    Text("Select a photo")
                }
                .onChange(of: selectedItem) { newItem in
                    Task {
                        // Retrieve selected asset in the form of Data
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            selectedImageData = data
                            if let image = UIImage(data: data) {
                                viewModel.classifyImage(image)
                            }
                        }
                    }
                }
        }
        
        
        if let selectedImageData,
           let uiImage = UIImage(data: selectedImageData) {
            ZStack {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: uiImage.size.width, height: uiImage.size.height)
                Rectangle().path(in: viewModel.rect ?? .zero).foregroundColor(.red.opacity(0.5))
            }
            .compositingGroup()
            .frame(width: uiImage.size.width, height: uiImage.size.height)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
