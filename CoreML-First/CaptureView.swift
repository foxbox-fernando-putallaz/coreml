//
//  CaptureView.swift
//  CoreML-First
//
//  Created by Fernando Putallaz on 25/09/2023.
//

import AVFoundation
import SwiftUI
import Vision

struct FrameView: View {
    var image: CGImage?
    private let label = Text("frame")
    @State var isShowingAlert = false
    @State var alertTitle = ""
    
    var body: some View {
        if let image {
            Image(image, scale: 1.0, orientation: .up, label: label)
                .onChange(of: image) {
                    detectImage(image)
                }
        } else {
            Color.green
        }
    }
    
    func detectImage(_ cgImage: CGImage) {
        let ciImage = CIImage(cgImage: cgImage)
        
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
                print("ml123 description: \(description)")
                print("ml123 confidence: \(confidence)")
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

struct CaptureView: View {
    @StateObject private var model = CameraManager()
    
    var body: some View {
        FrameView(image: model.frame)
            .ignoresSafeArea()
    }
}

#Preview {
    CaptureView()
}
