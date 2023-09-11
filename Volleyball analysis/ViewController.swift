//
//  ViewController.swift
//  Volleyball analysis
//
//  Created by Pieter Bikkel on 05/09/2023.
//

import UIKit
import SwiftUI
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    private var permissionGranted = false // Flag for permission
    
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    
    private var previewLayer = AVCaptureVideoPreviewLayer()
    var screenRect: CGRect! = nil // For view dimensions
    
    // Detector
    private var videoOutput = AVCaptureVideoDataOutput()
    
    override func viewDidLoad() {
        checkPermission()
        
        sessionQueue.async { [unowned self] in
            guard permissionGranted else { return }
            self.setupCaptureSession()
            self.captureSession.startRunning()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
            
        if UIDevice.current.orientation.rawValue == 4 {
            self.previewLayer.connection?.videoRotationAngle = 180.0
        } else if UIDevice.current.orientation.rawValue == 3 {
            self.previewLayer.connection?.videoRotationAngle = 0.0
        }
            
    }
    
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            // Permission has been granted before
        case .authorized:
            permissionGranted = true
            
            // Permission has not been requested yet
        case .notDetermined:
            requestPermission()
            
        default:
            permissionGranted = false
        }
    }
    
    func requestPermission() {
        sessionQueue.suspend()
        AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
            self.permissionGranted = granted
            self.sessionQueue.resume()
        }
    }
    
    func setupCaptureSession() {
        // Access the camera
        guard let videoDevice = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) else { return }
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
        
        guard captureSession.canAddInput(videoDeviceInput) else { return }
        captureSession.addInput(videoDeviceInput)
        
        // Add preview layer
        screenRect = UIScreen.main.bounds
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill // fill the screen
        
        let rotationCoordinator = videoDeviceInput
        
        if UIDevice.current.orientation.rawValue == 4 {
            self.previewLayer.connection?.videoRotationAngle = 180.0
        } else if UIDevice.current.orientation.rawValue == 3 {
            self.previewLayer.connection?.videoRotationAngle = 0.0
        } else {
            self.previewLayer.connection?.videoRotationAngle = 0.0
        }
        
        captureSession.addOutput(videoOutput)
        
        videoOutput.connection(with: .video)?.videoRotationAngle = 0.0
        
        // Updates to UI must be on the main queue
        DispatchQueue.main.async { [weak self] in
            self!.view.layer.addSublayer(self!.previewLayer)
        }
    }
}

struct HostedViewController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        return ViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}
