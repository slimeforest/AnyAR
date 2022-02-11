import UIKit
import SceneKit
import ARKit
import SceneKit.ModelIO

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var userItemView: UICollectionView!

    
    
    
    
    
    var itemArray = [Item]()
    let thumbGenerator = GenerateThumbnail()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.automaticallyUpdatesLighting = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        userItemView.dataSource = self
        userItemView.allowsSelection = true
        userItemView.allowsMultipleSelection = false
        userItemView.delegate = self
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
    
    //MARK: - placing objects
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touchLocation = touches.first?.location(in: sceneView) {
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            
            if let hitResult = hitTestResults.first {
                addObject(at: hitResult)
                print("object has been placed")
            }
        }
    }
    
    func addObject(at hitResult: ARHitTestResult){
        var objectToAdd = SCNNode()
        let location = SCNVector3(x: hitResult.worldTransform.columns.3.x, y: hitResult.worldTransform.columns.3.y, z: hitResult.worldTransform.columns.3.z)
        let itemScale = SCNVector3(0.0005, 0.0005, 0.0005)
        
        for var item in itemArray {
            if item.isSelected {
                objectToAdd = item.itemNode
                objectToAdd.position = location
                objectToAdd.scale = itemScale

                sceneView.scene.rootNode.addChildNode(objectToAdd)
            }else {
                print("\(item.itemName) was not set")
            }
        }
    }
    
    //MARK: - buttons pressed
    
    @IBAction func leftItemButtonPressed(_ sender: Any) {
        if userItemView.isHidden {
            userItemView.isHidden = false
        }else {
            userItemView.isHidden = true
        }
    }
    
    @IBAction func rightItemButtonPressed(_ sender: Any) {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.usdz], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }
    
    //MARK: - sliders
    @IBOutlet weak var rotateSliderOutlet: UISlider!
    @IBOutlet weak var rotateLabelOutlet: UILabel!

    @IBOutlet weak var xAxisSliderOutlet: UISlider!
    @IBOutlet weak var xAxisLabelOutlet: UILabel!

    @IBOutlet weak var zAxisSliderOutlet: UISlider!
    @IBOutlet weak var zAxisLabelOutlet: UILabel!

    @IBOutlet weak var yAxisSliderOutlet: UISlider!
    @IBOutlet weak var yAxisLabelOutlet: UILabel!
    
    
    @IBAction func controlButtonPressed(_ sender: Any) {
        toggleControls()
    }
    
    
    
    
    func toggleControls() {
        if rotateSliderOutlet.isEnabled &&
            rotateLabelOutlet.isEnabled &&
            xAxisSliderOutlet.isEnabled &&
            xAxisLabelOutlet.isEnabled &&
            yAxisSliderOutlet.isEnabled &&
            yAxisLabelOutlet.isEnabled &&
            zAxisSliderOutlet.isEnabled &&
            zAxisLabelOutlet.isEnabled {
            
            rotateSliderOutlet.isEnabled = false
            rotateLabelOutlet.isEnabled = false
            xAxisSliderOutlet.isEnabled = false
            xAxisLabelOutlet.isEnabled = false
            yAxisSliderOutlet.isEnabled = false
            yAxisLabelOutlet.isEnabled = false
            zAxisSliderOutlet.isEnabled = false
            zAxisLabelOutlet.isEnabled = false
            
            rotateSliderOutlet.isHidden = true
            rotateLabelOutlet.isHidden = true
            xAxisSliderOutlet.isHidden = true
            xAxisLabelOutlet.isHidden = true
            yAxisSliderOutlet.isHidden = true
            yAxisLabelOutlet.isHidden = true
            zAxisSliderOutlet.isHidden = true
            zAxisLabelOutlet.isHidden = true
            
        }else {
            rotateSliderOutlet.isEnabled = true
            rotateLabelOutlet.isEnabled = true
            xAxisSliderOutlet.isEnabled = true
            xAxisLabelOutlet.isEnabled = true
            yAxisSliderOutlet.isEnabled = true
            yAxisLabelOutlet.isEnabled = true
            zAxisSliderOutlet.isEnabled = true
            zAxisLabelOutlet.isEnabled = true
            
            rotateSliderOutlet.isHidden = false
            rotateLabelOutlet.isHidden = false
            xAxisSliderOutlet.isHidden = false
            xAxisLabelOutlet.isHidden = false
            yAxisSliderOutlet.isHidden = false
            yAxisLabelOutlet.isHidden = false
            zAxisSliderOutlet.isHidden = false
            zAxisLabelOutlet.isHidden = false
        }
    }
    
    
    
    @IBAction func rotateSlider(_ sender: Any) {
        print("rotate slider changed")
    }
    
    @IBAction func xAxisSlider(_ sender: Any) {
        print("x axis slider changed")
    }
    
    @IBAction func zAxisSlider(_ sender: Any) {
        print("z axis slider changed")
    }
    
    @IBAction func yAxisSlider(_ sender: Any) {
        print("y axis slider changed")
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
        
        let newItem = Item(node: mdlNode, name: modelName, url: selectedFileURL, image: modelTHumb, selected: false)
        
        itemArray.append(newItem)
        userItemView.reloadData()
        print("Item array when new item has been set: \(itemArray)")
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

        if itemArray[indexPath.row].isSelected == false {
            for item in itemArray {
                item.isSelected = false
            }
            itemArray[indexPath.row].isSelected = true
            userItemView.cellForItem(at: indexPath)?.isSelected = true
        }else if itemArray[indexPath.row].isSelected == true {
            itemArray[indexPath.row].isSelected = false
            userItemView.cellForItem(at: indexPath)?.isSelected = false
        }
        userItemView.reloadData()
    }
}
//MARK: - sliders
extension ViewController {
    
  
}

