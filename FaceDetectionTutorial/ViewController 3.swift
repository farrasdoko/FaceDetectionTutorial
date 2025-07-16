//
//  ViewController3.swift
//  FaceDetectionTutorial
//
//  Created by Doko Farras on 14/07/25.
//

import UIKit
import AVFoundation
import Vision

class ViewController3: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private let session = AVCaptureSession()
    private let previewLayer = AVCaptureVideoPreviewLayer()
    private var currentCameraPosition: AVCaptureDevice.Position = .back
    private var faceLayers: [CAShapeLayer] = []
    private let videoQueue = DispatchQueue(label: "videoQueue")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCamera()
        setupDoubleToFlip()
    }
    
    private func setupCamera() {
        session.sessionPreset = .photo
        
        guard let input = configureCameraInput(for: currentCameraPosition) else { return }
        session.addInput(input)
        
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: videoQueue)
        session.addOutput(output)
        
        previewLayer.session = session
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }
    
    private func flipCamera() {
        DispatchQueue.global().async {
            self.session.beginConfiguration()
            
            if let currentInput = self.session.inputs.first {
                self.session.removeInput(currentInput)
            }
            
            self.currentCameraPosition = self.currentCameraPosition == .back ? .front : .back
            if let input = self.configureCameraInput(for: self.currentCameraPosition) {
                self.session.addInput(input)
            }
            
            self.session.commitConfiguration()
        }
    }
    
    private func configureCameraInput(for position: AVCaptureDevice.Position) -> AVCaptureDeviceInput? {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else { return nil }
        return input
    }
    
    private func setupDoubleToFlip() {
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapGesture)
    }
    
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        flipCamera()
    }
    
    // Process each frame
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let request = VNDetectFaceRectanglesRequest { [weak self] request, error in
            DispatchQueue.main.async {
                guard let self = self,
                      let results = request.results as? [VNFaceObservation] else { return }
                self.handleDetectedFaces(results)
            }
        }
        
        let orientation = CGImagePropertyOrientation(deviceOrientation: UIDevice.current.orientation)
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation, options: [:])
        try? handler.perform([request])
    }
    
    private func handleDetectedFaces(_ results: [VNFaceObservation]) {
        DispatchQueue.main.async {
            self.faceLayers.forEach { $0.removeFromSuperlayer() }
            self.faceLayers.removeAll()
            
            for face in results {
                let rect = self.transformBoundingBox(face.boundingBox)
                let layer = self.createFaceLayer(frame: rect)
                self.view.layer.addSublayer(layer)
                self.faceLayers.append(layer)
            }
        }
    }
    
    private func transformBoundingBox(_ boundingBox: CGRect) -> CGRect {
        var originX = boundingBox.minX * view.bounds.width
        let originY = (1 - boundingBox.minY - boundingBox.height) * view.bounds.height
        let width = boundingBox.width * view.bounds.width
        let height = boundingBox.height * view.bounds.height
        
        if currentCameraPosition == .front {
            originX = view.bounds.width - originX - width
        }
        
        return CGRect(x: originX, y: originY, width: width, height: height)
    }
    
    private func createFaceLayer(frame: CGRect) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.frame = frame
        layer.borderColor = UIColor.red.cgColor
        layer.borderWidth = 2
        layer.cornerRadius = 4
        return layer
    }
    
}
