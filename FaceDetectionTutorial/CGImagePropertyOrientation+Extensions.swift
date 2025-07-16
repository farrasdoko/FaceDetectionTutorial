//
//  CGImagePropertyOrientation+Extensions.swift
//  FaceDetectionTutorial
//
//  Created by Doko Farras on 16/07/25.
//

import UIKit

extension CGImagePropertyOrientation {
    init(deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .portraitUpsideDown: self = .left
        case .landscapeLeft:      self = .upMirrored
        case .landscapeRight:     self = .down
        default:                  self = .right
        }
    }
}
