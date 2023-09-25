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
    @State var imageDescription: String = ""
    @State var accuracyConfidence: String = ""
    @State var isShowingAlert = false
    @State var alertTitle = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                if let data, let uiImage = UIImage(data: data) {
                    ImageCard(image: uiImage, title: imageDescription, accuracy: accuracyConfidence)
                        .alert(alertTitle, isPresented: $isShowingAlert) {
                            Button("Ok", role: .cancel) { }
                        } message: {
                            Text("Please pick another image")
                        }
                }
            }
            .frame(maxHeight: 300)
            .navigationTitle(imageSelected ? "Your Image" : "Select an image")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    PhotosPicker(selection: $selectedImages, maxSelectionCount: 1, matching: .images) {
                        Image(systemName: "photo.on.rectangle.angled")
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
    
    func convertImage(_ imageData: Data) {
        guard let ciImage = CIImage(data: imageData) else {
            return
        }
        
        detectImage(ciImage)
    }
    
    //MARK: - Probably old way of doing things :eyes:
    
    func detectImage(_ ciImage: CIImage) {
        guard let model = try? VNCoreMLModel(for: Resnet50(configuration: .init()).model) else {
            return
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation] else {
                isShowingAlert = true
                alertTitle = "error loading the results"
                return
            }
            let firstResult = results.first
            
            if let description = firstResult?.identifier, let confidence = firstResult?.confidence {
                imageDescription = description
                accuracyConfidence = "\(confidence)"
            }
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
    NavigationStack {
        VStack(spacing: 32.0) {
            ImageCard(image: UIImage(named: "taylor2")!, title: "Evening Dance, when probable is Taylor Swift and this is not being accurate at all.", accuracy: "0.49591")
            ImageCard(image: UIImage(named: "mustang1")!, title: "Sports Car, Sport Car, Super Sport Car", accuracy: "0.49591")
            ImageCard(image: UIImage(named: "mustang1")!, title: "Sports Car, Sport Car, Super Sport Car", accuracy: "0.49591")
        }
    }
}
