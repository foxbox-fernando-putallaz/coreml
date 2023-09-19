//
//  ContentView.swift
//  CoreML-First
//
//  Created by Fernando Putallaz on 18/09/2023.
//

import SwiftUI
import PhotosUI

struct ContentView: View {
    @State var selectedImages: [PhotosPickerItem] = []
    @State var data: Data?
    @State var imageSelected = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    if let data, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .frame(width: 200, height: 200)
                            .cornerRadius(30)
                            .shadow(radius: 10)
                            .padding()
                    }
                }
                .navigationTitle(imageSelected ? "Your Image" : "Select an image")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        PhotosPicker(
                            selection: $selectedImages,
                            maxSelectionCount: 1,
                            matching: .images
                        ) {
                            Image(systemName: "photo.badge.plus")
                        }
                    }
                }
                .onChange(of: selectedImages) {
                    guard let item = selectedImages.first else {
                        return
                    }
                    
                    item.loadTransferable(type: Data.self) { result in
                        switch result {
                        case .success(let item):
                            if let data = item {
                                self.data = data
                                imageSelected = true
                            }
                        case .failure(let error):
                            fatalError("error \(error.localizedDescription)")
                        }
                    }
                    
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
