//
//  WikiFace.swift
//  FaceDetectionTutorial
//
//  Created by Doko Farras on 15/07/25.
//

import UIKit
import ImageIO

class WikiFace {
    class func wikiForPerson(name: String?) async -> UIImage? {
        guard let text = name?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
              let url = URL(string: "https://en.wikipedia.org/w/api.php?action=query&titles=\(text)&prop=pageimages&format=json&pithumbsize=400") else {
            return nil
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let query = json["query"] as? [String: Any],
                  let pages = query["pages"] as? [String: Any],
                  let firstPage = pages.values.first as? [String: Any],
                  let thumbnail = firstPage["thumbnail"] as? [String: Any],
                  let sourceStr = thumbnail["source"] as? String,
                  let imageURL = URL(string: sourceStr),
                  let imageData = try? Data(contentsOf: imageURL),
                  let image = UIImage(data: imageData) else {
                return nil
            }
            
            return image
        } catch {
            print("Error fetching image: \(error)")
            return nil
        }
    }
    
    class func centerImageOnFace(on imageView: UIImageView) {
        let context = CIContext(options: nil)
        let options = [CIDetectorAccuracy:CIDetectorAccuracyHigh]
        guard let detector = CIDetector(ofType: CIDetectorTypeFace, context: context, options: options),
              let image = imageView.image,
              let cgImage = image.cgImage else { return }
        
        let ciImage = CIImage(cgImage: cgImage)
        let features = detector.features(in: ciImage)
        
        let imageSize = image.size
        
        let rect = features.first
        guard let face: CIFaceFeature = rect as? CIFaceFeature else { return }
        
        let faceBounds = face.bounds
        let x = faceBounds.origin.x / imageSize.width
        // normalize and flip vertically to account for different coordinate systems.
        // To map Core Image's face bounding box into CALayer space, need to flip the Y coordinate:
        // Because Core Image and CALayer use different coordinate systems.
        // Framework  |  Origin (0,0)  |  Direction of Y-axis
        // Core Image (CIImage, face.bounds)  |  bottom-left  |  Up
        // Core Animation (CALayer, contentsRect)  |  top-left  |  Down
        let y = (imageSize.height - faceBounds.origin.y - faceBounds.height) / imageSize.height
        let width = faceBounds.width / imageSize.width
        let height = faceBounds.height / imageSize.height
        
        imageView.layer.contentsRect = CGRect(x: x, y: y, width: width, height: height)
    }
    
    class func drawFaceBoxes(on imageView: UIImageView) {
        let context = CIContext(options: nil)
        let options = [CIDetectorAccuracy:CIDetectorAccuracyHigh]
        guard let detector = CIDetector(ofType: CIDetectorTypeFace, context: context, options: options),
              let image = imageView.image,
              let cgImage = image.cgImage else { return }
        
        let ciImage = CIImage(cgImage: cgImage)
        let features = detector.features(in: ciImage)
        
        // Remove previous face layers if any
        imageView.layer.sublayers?.removeAll(where: { $0.name == "FaceBox" })
        
        let imageSize = image.size
        let viewSize = imageView.bounds.size
        
        let scaleX = viewSize.width / imageSize.width
        let scaleY = viewSize.height / imageSize.height
        
        for feature in features {
            guard let face = feature as? CIFaceFeature else { continue }
            
            // Flip Y and scale
            let faceRect = CGRect(
                x: face.bounds.origin.x * scaleX,
                y: (imageSize.height - face.bounds.origin.y - face.bounds.height) * scaleY,
                width: face.bounds.width * scaleX,
                height: face.bounds.height * scaleY
            )
            
            let boxLayer = CAShapeLayer()
            boxLayer.name = "FaceBox"
            boxLayer.frame = faceRect
            boxLayer.borderColor = UIColor.green.cgColor
            boxLayer.borderWidth = 2.0
            imageView.layer.addSublayer(boxLayer)
        }
    }
}
