//
//  ImagePreviewVC.swift
//  AnyAR
//
//  Created by Jack Battle on 3/17/22.
//

import Foundation
import UIKit

class ImagePreviewVC: UIViewController {
    
    @IBOutlet weak var imagePreviewOutlet: UIImageView!
    var image = UIImage()
    override func viewDidLoad() {
        updateViews()
    }
    func updateViews(){
        imagePreviewOutlet.image = image
    }
    
}
