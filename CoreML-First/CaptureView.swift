//
//  CaptureView.swift
//  CoreML-First
//
//  Created by Fernando Putallaz on 25/09/2023.
//

import AVFoundation
import SwiftUI

struct FrameView: View {
    var image: CGImage?
    private let label = Text("frame")
    
    var body: some View {
        if let image {
            Image(image, scale: 1.0, orientation: .up, label: label)
        } else {
            Color.green
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
