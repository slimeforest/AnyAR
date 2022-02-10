//
//  UserItemCellCollectionViewCell.swift
//  AnyAR
//
//  Created by Jack Battle on 2/9/22.
//

import UIKit

class UserItemCellCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    
    func config(_ name: String) {
        nameLabel.text = name
//        print("name has been set")
    }
   
}
