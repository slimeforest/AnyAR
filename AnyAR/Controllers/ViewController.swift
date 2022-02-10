//
//  ViewController.swift
//  AnyAR
//
//  Created by Jack Battle on 1/20/22.
//

import UIKit
import SceneKit
import ARKit
import SceneKit.ModelIO

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var userItemView: UICollectionView!
    
    var itemArray = [Item]()
    let thumbGenerator = GenerateThumbnail()
    
    var objectToRender = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.automaticallyUpdatesLighting = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        userItemView.dataSource = self
        userItemView.allowsSelection = true
        userItemView.allowsMultipleSelection = false
        userItemView.delegate = self
        // Create a new scene
        //                let scene = SCNScene(named: "art.scnassets/ship.scn")!
        //
        //                // Set the scene to the view
        //                sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        
//        configuration.sceneReconstruction = true
        
    
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    
    //MARK: - placing objects
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            let results = sceneView.hitTest(touchLocation, types: .featurePoint)
            if let hitResult = results.first {
                
                for item in itemArray {
                    if item.isSelected {
                        item.itemNode.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z * 10000)
                        
                        print("Your hit result is: \(hitResult)")
                        sceneView.scene.rootNode.addChildNode(item.itemNode)
                    }
                }
            }
        }
    }
    
    func placeObject(position: SCNVector3) {
        for item in itemArray {
            if item.isSelected {
                item.itemNode.position = position
                sceneView.scene.rootNode.addChildNode(item.itemNode)
            }
        }
    }
    
    //MARK: session
    
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    //MARK: - buttons pressed
    @IBAction func fileButtonPressed(_ sender: Any) {
        if userItemView.isHidden {
            userItemView.isHidden = false
        }else {
            userItemView.isHidden = true
        }
    }
    
    @IBAction func openFilesPressed(_ sender: Any) {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.usdz], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }
}

//MARK: - document picker
extension ViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print("document chosen")
        
        guard let selectedFileURL = urls.first else {
            return
        }
        
        let modelName = selectedFileURL.lastPathComponent
        let modelTHumb = (thumbGenerator.thumbnail(for: selectedFileURL, size: CGSize(width: 150, height: 150), time: 0) ?? UIImage(named: "doc.plaintext.fill"))!
        
        
        
        let mdlAsset = MDLAsset(url: selectedFileURL)
        mdlAsset.loadTextures()
        let mdlNode = SCNNode(mdlObject: mdlAsset.object(at: 0))
        
        let newItem = Item(itemNode: mdlNode, itemName: modelName, itemURL: selectedFileURL, itemImage: modelTHumb, isSelected: false)
        
        itemArray.append(newItem)
        userItemView.reloadData()
        
        //        mdlNode.position.z = -1000
        //
        //        sceneView.scene.rootNode.addChildNode(mdlNode)
        
    }
}


//MARK: - user item collection
extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = UICollectionViewCell()
        
        if let itemCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as? UserItemCellCollectionViewCell {
            
            itemCell.config(itemArray[indexPath.row])
            
            cell = itemCell
            
        }
        return cell
    }
    
}

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //        userItemView.deselectItem(at: indexPath, animated: true)
        if itemArray[indexPath.row].isSelected {
            itemArray[indexPath.row].isSelected = false
        }else {
            itemArray[indexPath.row].isSelected = true
        }
        
        print(itemArray[indexPath.row].itemName)
    }
    
}
