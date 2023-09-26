//
//  CameraManager.swift
//  CoreML-First
//
//  Created by Fernando Putallaz on 25/09/2023.
//

import AVFoundation
import CoreImage

class CameraManager: NSObject, ObservableObject {
    @Published var frame: CGImage?
    private var permissionGranted = false
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    private let context = CIContext()
    
    override init() {
        super.init()
        
        checkPermission()
        sessionQueue.async { [unowned self] in
            self.setupCaptureSession()
            self.captureSession.startRunning()
        }
    }
    
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionGranted = true
            
        case .notDetermined:
            requestPermission()
            
        default:
            permissionGranted = false
        }
    }
    
    func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
            self.permissionGranted = granted
        }
    }
    
    func setupCaptureSession() {
        let videoOutput = AVCaptureVideoDataOutput()
        
        guard permissionGranted else { return }
        guard let videoDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) else { return }
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
        guard captureSession.canAddInput(videoDeviceInput) else { return }
        
        captureSession.addInput(videoDeviceInput)
        
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sampleBufferQueue"))
        captureSession.addOutput(videoOutput)
        videoOutput.connection(with: .video)?.videoRotationAngle = 90
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let cgImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
        
        DispatchQueue.main.async {
            self.frame = cgImage
        }
    }
    
    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> CGImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
         guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        
        return cgImage
        
    }
}

/*
 
 Probably the modern way to go but need to deal with async/await a little more.
     let captureSession = AVCaptureSession()
 
     override init() async {
        await setupCaptureSession()
     }
 
     var isAuthorized: Bool {
         get async {
             let status = AVCaptureDevice.authorizationStatus(for: .video)
 
             var isAuthorized = status == .authorized
 
             if status == .notDetermined {
                 isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
             }
 
             return isAuthorized
         }
     }
 
     func setupCaptureSession() async  {
         guard await isAuthorized else { return }
 
 
 
         captureSession.beginConfiguration()
 
         let cameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back)
 
         do {
             let videoInput = try AVCaptureDeviceInput(device: cameraDevice!)
 
             if captureSession.canAddInput(videoInput) {
                 captureSession.addInput(videoInput)
             }
         } catch {
             //catch the error
         }
 
         setOutput()
     }
 
     func setOutput() {
         let videoOutput = AVCaptureVideoDataOutput()
         videoOutput.setSampleBufferDelegate(self, queue: .main)
         captureSession.addOutput(videoOutput)
         videoOutput.connection(with: .video)?.videoOrientation = .portrait
     }
 */
