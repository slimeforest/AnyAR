import UIKit
import SceneKit
import ARKit
import SceneKit.ModelIO

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var userItemView: UICollectionView!
    
    
    var userImage = UIImage() {
        didSet {
            self.performSegue(withIdentifier: "goToImagePreview", sender: self)
            sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        }
    }
    
    var selectedIndexPath: IndexPath = []{
        didSet{
            userItemView.reloadData()
        }
    }
    
    var itemArray = [Item]()
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
        userItemView.isHidden = false
        
        userItemView.layer.cornerRadius = 10
        userItemView.backgroundColor = UIColor.systemCyan.withAlphaComponent(0.2)
        
        
        captureButtonOutlet.layer.borderColor = UIColor.systemBlue.cgColor
        captureButtonOutlet.layer.borderWidth = 1.0
        captureButtonOutlet.layer.cornerRadius = 5
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
                print("\(item.itemName) was set")
                
            }else {
                print("\(item.itemName) was not set")
            }
        }
    }
    //MARK: - buttons pressed
    
    @IBOutlet weak var captureButtonOutlet: UIButton!
    
    @IBAction func leftItemButtonPressed(_ sender: Any) {
        toggleUImode()
    }
    
    func toggleUImode() {
        if userItemView.isHidden && controlButtonOutlet.isHidden && scaleSliderOutlet.isHidden && rotateSliderOutlet.isHidden && scaleLabelOutlet.isHidden && rotateLabelOutlet.isHidden && captureButtonOutlet.isHidden == false {
            
            userItemView.isHidden = false
            
            controlButtonOutlet.isHidden = false
            controlButtonOutlet.isEnabled = true
            
            scaleSliderOutlet.isHidden = false
            scaleSliderOutlet.isEnabled = true
            scaleLabelOutlet.isHidden = false
            scaleLabelOutlet.isEnabled = true
            
            rotateSliderOutlet.isHidden = false
            rotateSliderOutlet.isEnabled = true
            
            rotateLabelOutlet.isHidden = false
            rotateLabelOutlet.isEnabled
            
            captureButtonOutlet.isHidden = true
            captureButtonOutlet.isEnabled = false
            
            sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]

        }else {
            userItemView.isHidden = true
            
            controlButtonOutlet.isHidden = true
            controlButtonOutlet.isEnabled = false
            
            scaleSliderOutlet.isHidden = true
            scaleSliderOutlet.isEnabled = false
            scaleLabelOutlet.isHidden = true
            scaleLabelOutlet.isEnabled = false
            
            rotateSliderOutlet.isHidden = true
            rotateSliderOutlet.isEnabled = false
            
            rotateLabelOutlet.isHidden = true
            rotateLabelOutlet.isEnabled
            
            captureButtonOutlet.isHidden = false
            captureButtonOutlet.isEnabled = true
            
            sceneView.debugOptions = []
        }
    }
    
    @IBAction func rightItemButtonPressed(_ sender: Any) {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.usdz], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }
    
    @IBAction func captureButtonPressed(_ sender: Any) {
        let image: UIImage = sceneView.snapshot()
        sceneView.debugOptions = []
        self.userImage = image
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToImagePreview" {
            let destinationVC = segue.destination as? ImagePreviewVC
            destinationVC?.image = self.userImage
        }
    }
    
    //MARK: - sliders
    @IBOutlet weak var rotateSliderOutlet: UISlider!
    @IBOutlet weak var rotateLabelOutlet: UILabel!
    
    @IBOutlet weak var scaleSliderOutlet: UISlider!
    @IBOutlet weak var scaleLabelOutlet: UILabel!
    
    @IBOutlet weak var controlButtonOutlet: UIButton!
    
    @IBAction func controlButtonPressed(_ sender: Any) {
        toggleControls()
    }
    
    func toggleControls() {
        if rotateSliderOutlet.isEnabled &&
            rotateLabelOutlet.isEnabled &&
            scaleSliderOutlet.isEnabled &&
            scaleLabelOutlet.isEnabled {
            
            rotateSliderOutlet.isEnabled = false
            rotateLabelOutlet.isEnabled = false
            scaleSliderOutlet.isEnabled = false
            scaleLabelOutlet.isEnabled = false
            
            rotateSliderOutlet.isHidden = true
            rotateLabelOutlet.isHidden = true
            scaleSliderOutlet.isHidden = true
            scaleLabelOutlet.isHidden = true
            
        }else {
            rotateSliderOutlet.isEnabled = true
            rotateLabelOutlet.isEnabled = true
            scaleSliderOutlet.isEnabled = true
            scaleLabelOutlet.isEnabled = true
            
            rotateSliderOutlet.isHidden = false
            rotateLabelOutlet.isHidden = false
            scaleSliderOutlet.isHidden = false
            scaleLabelOutlet.isHidden = false
        }
    }
    
    @IBAction func rotateSlider(_ sender: UISlider) {
        let value = sender.value
        let roundedValue = Int(round(value))
        print(roundedValue)
        let negRange = (-16)...(-1)
        let posRange = 1...16
        
        for item in itemArray {
            if item.isSelected {
                let originalEulerAngle = item.itemNode.eulerAngles.y
                
                if negRange.contains(roundedValue) || posRange.contains(roundedValue) {
                    item.itemNode.eulerAngles.y = .pi/Float(roundedValue)
                }else {
                    item.itemNode.eulerAngles.y = originalEulerAngle
                }
            }
        }
    }
    
    @IBAction func scaleSlider(_ sender: UISlider) {
        print("working")
    }
    //
    //    @IBAction func scaleSlider(_ sender: UISlider) {
    //        print("scale slider changed")
    //        let value = sender.value * 0.005
    //        let scale = SCNVector3(x: value, y: value, z: value)
    //
    //        for item in itemArray {
    //            if item.isSelected {
    //                item.itemNode.scale.x = item.itemNode.scale.x * value
    //                item.itemNode.scale.y = item.itemNode.scale.y * value
    //                item.itemNode.scale.z = item.itemNode.scale.z * value
    //            }
    //        }
    //    }
    //}
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
            
            var borderColor = UIColor.clear.cgColor
            var borderWidth: CGFloat = 0
            let cornerRadius = 10.0
            
            if indexPath == selectedIndexPath{
                borderColor = UIColor.systemBlue.cgColor
                borderWidth = 2 //or whatever you please
                
            }else{
                borderColor = UIColor.clear.cgColor
                borderWidth = 0
            }
            
            itemCell.layer.borderWidth = borderWidth
            itemCell.layer.borderColor = borderColor
            itemCell.layer.cornerRadius = cornerRadius
            cell = itemCell
        }
        cell.layoutIfNeeded()
        return cell
    }
    
}

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        for item in itemArray {
            item.isSelected = false
        }
        itemArray[indexPath.row].isSelected = true
        
        userItemView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        selectedIndexPath = indexPath
        userItemView.reloadData()
    }
}
