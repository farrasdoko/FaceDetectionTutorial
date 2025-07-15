//
//  ViewController2.swift
//  FaceDetectionTutorial
//
//  Created by Doko Farras on 14/07/25.
//

import UIKit

class ViewController2: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var tf: UITextField!
    @IBOutlet weak var iv: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        Task {
            let image = await WikiFace.wikiForPerson(name: textField.text)
            await MainActor.run {
                iv.image = image
                WikiFace.drawFaceBoxes(on: iv)
            }
        }
        return true
    }
}
