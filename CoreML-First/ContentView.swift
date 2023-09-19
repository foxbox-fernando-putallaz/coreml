//
//  ContentView.swift
//  CoreML-First
//
//  Created by Fernando Putallaz on 18/09/2023.
//

import PhotosUI
import SwiftUI
import Vision

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
                            .aspectRatio(contentMode: .fit)
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
                            if let imageData = item {
                                self.data = imageData
                                imageSelected = true
                                
                                convertImage(imageData)
                            }
                        case .failure(let error):
                            fatalError("error \(error.localizedDescription)")
                        }
                    }
                    
                }
            }
        }
    }
    
    func convertImage(_ imageData: Data) {
        guard let ciImage = CIImage(data: imageData) else {
            return
        }
        
        detectImage(ciImage)
    }
    
    
    //MARK: - Probably old way of doing things :eyes:
    
    func detectImage(_ ciImage: CIImage) {
        guard
            let model = try? VNCoreMLModel(for: Resnet50(configuration: .init()).model) else {
            return
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else {
                print("error loading the results")
                return
            }
            
            print(results)
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        
        do {
            try handler.perform([request])
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

#Preview {
    ContentView()
}
