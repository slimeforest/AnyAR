//
//  Item.swift
//  AnyAR
//
//  Created by Jack Battle on 2/9/22.
//

import Foundation
import SceneKit

struct Item {
    let itemNode: SCNNode
    let itemName: String
    let itemURL: URL
    let itemImage: UIImage
    var isSelected: Bool
}
