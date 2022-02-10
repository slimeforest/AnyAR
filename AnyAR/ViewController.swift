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
    
    let testSource = ["Auggie","Smith","Bing","Chilling"]
    
    var userItemArray = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.showsStatistics = false
        sceneView.automaticallyUpdatesLighting = true
        sceneView.automaticallyUpdatesLighting = true
        
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
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
        @IBAction func fileButtonPressed(_ sender: Any) {
//            print("suh dude")
//            let file = "\(UUID().uuidString).txt"
//            let contents = "Ride with the mob"
//
//            let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//            let fileURL = dir.appendingPathComponent(file)
//
//            do {
//                try contents.write(to: fileURL, atomically: false, encoding: .utf8)
//                print("file written")
//            }catch {
//                print("Error: \(error)")
//            }
            
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

extension ViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print("document chosen")
        
        guard let selectedFileURL = urls.first else {
            return
        }
        
        
        let mdlAsset = MDLAsset(url: selectedFileURL)
        mdlAsset.loadTextures()
        let mdlNode = SCNNode(mdlObject: mdlAsset.object(at: 0))
//        mdlNode.name = "User Item #\(userItemArray.count + 1)"
//        userItemArray.append(mdlNode)
//        for node in userItemArray {
//            print("User Item: \(node.name)")
//        }
        
        mdlNode.position.z = -1000

        sceneView.scene.rootNode.addChildNode(mdlNode)
    
    }
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return testSource.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = UICollectionViewCell()
        
        if let itemCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as? UserItemCellCollectionViewCell {
            
            itemCell.config(testSource[indexPath.row])
            
            cell = itemCell
            
        }
        return cell
    }
    
}

extension ViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        userItemView.deselectItem(at: indexPath, animated: true)
        print(testSource[indexPath.row])
        
        
    }

}
