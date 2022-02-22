import UIKit
import SceneKit
import ARKit
import SceneKit.ModelIO

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var userItemView: UICollectionView!

    var itemArray = [Item]()
    var renderArray = [RenderItem]()
    let thumbGenerator = GenerateThumbnail()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.showsStatistics = false
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
        var nodeToAdd = SCNNode()
        let location = SCNVector3(x: hitResult.worldTransform.columns.3.x, y: hitResult.worldTransform.columns.3.y, z: hitResult.worldTransform.columns.3.z)
        let itemScale = SCNVector3(0.0005, 0.0005, 0.0005)
        
        for var item in itemArray {
            if item.isSelected {
                nodeToAdd = item.itemNode
                nodeToAdd.position = location
                nodeToAdd.scale = itemScale
                
                sceneView.scene.rootNode.addChildNode(nodeToAdd)
            }else {
                print("\(item.itemName) was not set")
            }
        }
    }
    
    //MARK: - buttons pressed
    
    @IBAction func leftItemButtonPressed(_ sender: Any) {
        if userItemView.isHidden && controlButtonOutlet.isHidden {
            userItemView.isHidden = false
            
            controlButtonOutlet.isHidden = false
            controlButtonOutlet.isEnabled = true
        }else {
            userItemView.isHidden = true
            controlButtonOutlet.isHidden = true
            controlButtonOutlet.isEnabled = false
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
    
    @IBOutlet weak var scaleLabelOutlet: UILabel!
    @IBOutlet weak var scaleSliderOutlet: UISlider! {
        didSet{
            scaleSliderOutlet.transform = CGAffineTransform(rotationAngle: -Double.pi / 2)
        }
    }
    @IBOutlet weak var controlButtonOutlet: UIButton!
    
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
            zAxisLabelOutlet.isEnabled &&
            scaleSliderOutlet.isEnabled &&
            scaleLabelOutlet.isEnabled {
            
            rotateSliderOutlet.isEnabled = false
            rotateLabelOutlet.isEnabled = false
            xAxisSliderOutlet.isEnabled = false
            xAxisLabelOutlet.isEnabled = false
            yAxisSliderOutlet.isEnabled = false
            yAxisLabelOutlet.isEnabled = false
            zAxisSliderOutlet.isEnabled = false
            zAxisLabelOutlet.isEnabled = false
            scaleSliderOutlet.isEnabled = false
            scaleLabelOutlet.isEnabled = false
            
            rotateSliderOutlet.isHidden = true
            rotateLabelOutlet.isHidden = true
            xAxisSliderOutlet.isHidden = true
            xAxisLabelOutlet.isHidden = true
            yAxisSliderOutlet.isHidden = true
            yAxisLabelOutlet.isHidden = true
            zAxisSliderOutlet.isHidden = true
            zAxisLabelOutlet.isHidden = true
            scaleSliderOutlet.isHidden = true
            scaleLabelOutlet.isHidden = true
            
        }else {
            rotateSliderOutlet.isEnabled = true
            rotateLabelOutlet.isEnabled = true
            xAxisSliderOutlet.isEnabled = true
            xAxisLabelOutlet.isEnabled = true
            yAxisSliderOutlet.isEnabled = true
            yAxisLabelOutlet.isEnabled = true
            zAxisSliderOutlet.isEnabled = true
            zAxisLabelOutlet.isEnabled = true
            scaleSliderOutlet.isEnabled = true
            scaleLabelOutlet.isEnabled = true
            
            rotateSliderOutlet.isHidden = false
            rotateLabelOutlet.isHidden = false
            xAxisSliderOutlet.isHidden = false
            xAxisLabelOutlet.isHidden = false
            yAxisSliderOutlet.isHidden = false
            yAxisLabelOutlet.isHidden = false
            zAxisSliderOutlet.isHidden = false
            zAxisLabelOutlet.isHidden = false
            scaleSliderOutlet.isHidden = false
            scaleLabelOutlet.isHidden = false
        }
    }
    
    
    
    @IBAction func rotateSlider(_ sender: Any) {
        print("rotate slider changed")
    }
    
    @IBAction func xAxisSlider(_ sender: UISlider) {
        let value = sender.value * 0.005
        print("x axis slider value is: \(value)")
        for item in itemArray {
            if item.isSelected {
                item.itemNode.position.x = item.itemNode.position.x + value
            }
        }
    }
    
    @IBAction func zAxisSlider(_ sender: UISlider) {
        let value = sender.value * 0.005
        print("z axis slider value is: \(value)")
        for item in itemArray {
            if item.isSelected {
                item.itemNode.position.z = item.itemNode.position.z + value
            }
        }
    }
    
    @IBAction func yAxisSlider(_ sender: UISlider) {
        let value = sender.value * 0.005
        print("x axis slider value is: \(value)")
        for item in itemArray {
            if item.isSelected {
                item.itemNode.position.y = item.itemNode.position.y + value
            }
        }
    }
    
    @IBAction func scaleSlider(_ sender: UISlider) {
        print("scale slider changed")
        let value = sender.value * 0.005
        let scale = SCNVector3(x: value, y: value, z: value)
        
        for item in itemArray {
            if item.isSelected {
                item.itemNode.scale.x = item.itemNode.scale.x * value
                item.itemNode.scale.y = item.itemNode.scale.y * value
                item.itemNode.scale.z = item.itemNode.scale.z * value
            }
        }
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
    
    func highlight(_ index: IndexPath) {
        userItemView.cellForItem(at: index)?.layer.borderWidth = 2.0
        userItemView.cellForItem(at: index)?.layer.borderColor = UIColor.systemBlue.cgColor
        userItemView.cellForItem(at: index)?.layer.cornerRadius = 10
    }
    
//    func unhighlight(_ index: IndexPath) {
//        userItemView.cellForItem(at: index)?.layer.borderWidth = 0
//        userItemView.cellForItem(at: index)?.layer.borderColor = UIColor.clear.cgColor
//
//    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if itemArray[indexPath.row].isSelected == false {
            for item in itemArray {
                item.isSelected = false
            }
            itemArray[indexPath.row].isSelected = true
            
            
//            userItemView.cellForItem(at: indexPath)?.isHighlighted = true
            
            
        }else if itemArray[indexPath.row].isSelected == true {
            itemArray[indexPath.row].isSelected = false
            
            
//            userItemView.cellForItem(at: indexPath)?.isHighlighted = false
            
            
        }
        userItemView.reloadData()
    }
    
//    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
//        userItemView.cellForItem(at: indexPath)?.layer.borderWidth = 2.0
//        userItemView.cellForItem(at: indexPath)?.layer.borderColor = UIColor.systemBlue.cgColor
//        userItemView.cellForItem(at: indexPath)?.layer.cornerRadius = 10
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
//        userItemView.cellForItem(at: indexPath)?.layer.borderWidth = 2.0
//        userItemView.cellForItem(at: indexPath)?.layer.borderColor = UIColor.clear.cgColor
//    }
    
    
}
