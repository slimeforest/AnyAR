//
//  ImagePreviewVC.swift
//  AnyAR
//
//  Created by Jack Battle on 3/17/22.
//

import Foundation
import UIKit

class ImagePreviewVC: UIViewController {
    @IBOutlet weak var deleteButtonOutlet: UIButton!
    @IBOutlet weak var exportButtonOutlet: UIButton!
    @IBOutlet weak var imagePreviewOutlet: UIImageView!
    
    var image = UIImage()
    let mainVC = ViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
    }
    
    func updateUI(){
        imagePreviewOutlet.image = image
        
        exportButtonOutlet.layer.borderColor = UIColor.systemBlue.cgColor
        exportButtonOutlet.layer.borderWidth = 2.0
        exportButtonOutlet.layer.cornerRadius = 10
        
        deleteButtonOutlet.layer.borderColor = UIColor.systemRed.cgColor
        deleteButtonOutlet.layer.borderWidth = 2.0
        deleteButtonOutlet.layer.cornerRadius = 10
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func exportButtonPressed(_ sender: Any) {
        print("export pressed")
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {

            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Image has been saved to your photo library.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                self.dismiss(animated: true, completion: nil)
            }))
            present(ac, animated: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        mainVC.promptReview()
    }
    
}
