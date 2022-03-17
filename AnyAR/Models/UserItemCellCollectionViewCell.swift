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
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//
//
//        let highlightedCell = UICollectionViewCell()
//        highlightedCell.layer.borderColor = UIColor.systemBlue.cgColor
//        highlightedCell.layer.borderWidth = 2.0
//        highlightedCell.layer.cornerRadius = 10
//
//        let unhighlightedCell = UICollectionViewCell()
//        unhighlightedCell.layer.borderColor = UIColor.systemBlue.cgColor
//        unhighlightedCell.layer.borderWidth = 2.0
//        unhighlightedCell.layer.cornerRadius = 10
//    }
    func config(_ item: Item) {
        nameLabel.text = item.itemName
        nodeThumbnailPrev.image = item.itemImage
    }
   
}
