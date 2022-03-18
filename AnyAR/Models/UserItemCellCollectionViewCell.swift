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

    func config(_ item: Item) {
        nameLabel.text = item.itemName
        nodeThumbnailPrev.image = item.itemImage
    }
}
