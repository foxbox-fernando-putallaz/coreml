//
//  CoreML_FirstApp.swift
//  CoreML-First
//
//  Created by Fernando Putallaz on 18/09/2023.
//

import SwiftUI

@main
struct CoreML_FirstApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                PictureView()
                    .tabItem {
                        Image( systemName: "photo.fill")
                    }
                
                CaptureView()
                    .tabItem {
                        Image(systemName: "camera.shutter.button")
                    }
            }
        }
    }
}
