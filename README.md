# FaceDetectionTutorial

This project is a practical implementation of the face detection tutorial featured in the YouTube video:  
[🎥 iOS Swift Tutorial: Face detection](https://www.youtube.com/watch?v=62kUursmc4E)

## 📱 Overview

**FaceDetectionTutorial** demonstrates how to perform face detection in an image using Core Image and basic image layer manipulation. The main view includes two buttons:

- **Crop to Face**: Automatically crops the image to the first detected face using `imageView.layer.contentsRect`.
- **Box on Face**: Draws red rectangles on all detected faces using `CAShapeLayer` and `imageView.layer.addSublayer`.

## ✨ Features

- Face detection using `CIDetector` from the Core Image framework.
- Image cropping using `imageView.layer.contentsRect`.
- Drawing rectangles over faces using `CAShapeLayer`.
- Y-axis coordinate adjustment to account for the difference between Core Image and Core Animation coordinate systems.

## 📚 Topics Covered

- 💡 Core Image face detection (`CIDetector`)
- 🎯 Cropping an image layer using `contentsRect`
- 🖌️ Drawing shapes over images using `CAShapeLayer`
- 🔄 Converting between Core Image and UIKit coordinate systems

## 🧪 Usage

1. Run the project in Xcode.
2. Tap:
   - **"Crop to Face"** to center and crop the image to the first detected face.
   - **"Box on Face"** to draw rectangles around all detected faces in the image.

## 📂 Project Structure

- `centerImageOnFace(from:)`: Crops the image to the first detected face using normalized `contentsRect`.
- `drawFaceBoxes(on:)`: Draws green rectangles on all detected faces using `CAShapeLayer`.

## 🧱 Developed on

- iOS 18.5
- Swift 5
- Xcode 16.4

---

This project was created as a tutorial demo for face detection and image layer manipulation on iOS.

Feel free to clone, modify, or use this as a base for your own face detection projects!

