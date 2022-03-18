//
//  UserItemCellCollectionViewCell.swift
//  AnyAR
//
//  Created by Jack Battle on 2/9/22.
//

import UIKit
import SceneKit

class UserItemCellCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var nameLabel: UILabel!    
    @IBOutlet weak var nodeThumbnailPrev: UIImageView!
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                self.layer.borderColor = UIColor.systemBlue.cgColor
                self.layer.borderWidth = 2.0
                self.layer.cornerRadius = 10
                print("isSelected \(self.isSelected)")
            }else {
                self.layer.borderColor = UIColor.clear.cgColor
                self.layer.borderWidth = 0
                print("isSelectedNot \(self.isSelected)")
            }
        }
    }
    
    func config(_ item: Item) {
        nameLabel.text = item.itemName
        nodeThumbnailPrev.image = item.itemImage
    }
   
}
