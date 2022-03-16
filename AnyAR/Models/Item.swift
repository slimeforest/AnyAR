//
//  Item.swift
//  AnyAR
//
//  Created by Jack Battle on 2/9/22.
//

import Foundation
import SceneKit

class Item {
    let itemNode: SCNNode
    let itemName: String
    let itemURL: URL
    let itemImage: UIImage
    var isSelected: Bool
    
    
    init(node: SCNNode, name: String, url: URL, image: UIImage, selected: Bool) {
        itemNode = node
        itemName = name
        itemURL = url
        itemImage = image
        isSelected = selected
    }
}
