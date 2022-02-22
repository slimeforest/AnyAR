import Foundation
import SceneKit

class RenderItem {
    let renderNode: SCNNode
    let isSelected: Bool
    
    init(node: SCNNode, selected: Bool) {
        renderNode = node
        isSelected = selected
    }
}
