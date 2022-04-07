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
        didSet {
            userItemView.reloadData()
        }
    }
    
    var itemSelected = Int()
    
    var itemArray = [Item]()
    let thumbGenerator = GenerateThumbnail()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.showsStatistics = false
        sceneView.automaticallyUpdatesLighting = true
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.autoenablesDefaultLighting = true

        userItemView.dataSource = self
        userItemView.allowsSelection = true
        userItemView.allowsMultipleSelection = false
        userItemView.delegate = self
        userItemView.isHidden = false
        
        userItemView.layer.cornerRadius = 10
        userItemView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.6)
        
        captureButtonOutlet.layer.borderColor = UIColor.systemBlue.cgColor
        captureButtonOutlet.layer.borderWidth = 1.0
        captureButtonOutlet.layer.cornerRadius = 5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
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
        
        for item in itemArray {
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
    //MARK: - function buttons pressed
    
    @IBOutlet weak var captureButtonOutlet: UIButton!
    @IBOutlet weak var trashbuttonOutlet: UIButton!
    @IBOutlet weak var controlButtonsStackOutlet: UIStackView!
    
    @IBAction func trashButtonPressed(_ sender: Any) {
        for item in itemArray {
            if item.isSelected {
                item.itemNode.removeFromParentNode()
                itemArray.remove(at: itemSelected )
                userItemView.reloadData()
            }
        }
    }
    
    @IBAction func leftItemButtonPressed(_ sender: Any) {
        hideControls()
        toggleUImode()
    }
    
    func toggleUImode() {
        if controlButtonsStackOutlet.isHidden {
            controlButtonsStackOutlet.isHidden = false
            userItemView.isHidden = false
            captureButtonOutlet.isHidden = true
            captureButtonOutlet.isEnabled = false
            sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        }else {
            controlButtonsStackOutlet.isHidden = true
            userItemView.isHidden = true
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
    
    //MARK: - controls
    func hideControls() {
        button1StackOutlet.isHidden = true
        button2StackOutlet.isHidden = true
        button3StackOutlet.isHidden = true
    }
    @IBAction func helpButtonPressed(_ sender: Any) {
        showHelpAlert()
    }
    
    func showHelpAlert() {
        let titleAttributes = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 25)!, NSAttributedString.Key.foregroundColor: UIColor.black]
        let titleString = NSAttributedString(string: "How To Use", attributes: titleAttributes)
        let alert = UIAlertController(title: "", message: "- Import your own .usdz models from the button in the top right \n \n - Tap them in the dock to select them \n \n - The yellow dots are there to help visualize how your iPhone detects depth \n \n - Once an item is selected, tap anywhere in the camera view to place it \n \n - Use the controls above the dock to further customize the selected model", preferredStyle: .actionSheet)
        alert.setValue(titleString, forKey: "attributedTitle")
        alert.addAction(UIAlertAction(title: "Import included models", style: .default , handler:{ (UIAlertAction)in
            print("User click Approve button")
            self.populateCollectionView()
        }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:{ (UIAlertAction)in
            print("User click Dismiss button")
        }))
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }

    func populateCollectionView() {
        let fileURL = Bundle.main.url(forResource: "Moon", withExtension: "usdz")!
        let includedAsset = MDLAsset(url: fileURL)
        includedAsset.loadTextures()
        let assetNode = SCNNode(mdlObject: includedAsset.object(at: 0))
        let mdlLight = SCNLight()
        mdlLight.type = .directional
        mdlLight.intensity = 800
        mdlLight.temperature = 5750
        mdlLight.castsShadow = true
        assetNode.light = mdlLight
        let assetImage = (thumbGenerator.thumbnail(for: fileURL, size: CGSize(width: 150, height: 150)) ?? UIImage(named: "pencil"))!
        let includedItem = Item(node: assetNode, name: fileURL.lastPathComponent, url: fileURL, image: assetImage, selected: false)
        
        itemArray.append(includedItem)
        userItemView.reloadData()
    }
    
    // Sizing Button Items
    @IBOutlet weak var button1StackOutlet: UIStackView!
    @IBOutlet weak var controlButtonOutlet: UIButton!
    @IBOutlet weak var rotateSliderOutlet: UISlider!
    @IBOutlet weak var rotateLabelOutlet: UILabel!
    @IBOutlet weak var scaleSliderOutlet: UISlider!
    @IBOutlet weak var scaleLabelOutlet: UILabel!
    
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
        print("current value: \(sender.value)")
        let adjustedValue = sender.value * 0.00001
        
        for item in itemArray {
            if item.isSelected {
                item.itemNode.scale.x = adjustedValue
                item.itemNode.scale.y = adjustedValue
                item.itemNode.scale.z = adjustedValue
            }
        }
    }
    
    // Position Button Items
    
    @IBOutlet weak var button2StackOutlet: UIStackView!
    @IBOutlet weak var xAxisStepperOutlet: UIStepper!

    @IBAction func xAxisChanged(_ sender: UIStepper) {
        if (sender.value == 1) {
            print("up");
            sender.value = 0

            for item in itemArray {
                if item.isSelected {
                    item.itemNode.position.x += 0.005
                }
            }
        } else if (sender.value == -1) {
            print("down")
            sender.value = 0
            
            for item in itemArray {
                if item.isSelected {
                    item.itemNode.position.x -= 0.005
                }
            }
        }
    }
    
    @IBAction func yAxisChanged(_ sender: UIStepper) {
        if (sender.value == 1) {
            print("up");
            sender.value = 0

            for item in itemArray {
                if item.isSelected {
                    item.itemNode.position.y += 0.005
                }
            }
        } else if (sender.value == -1) {
            print("down")
            sender.value = 0
            
            for item in itemArray {
                if item.isSelected {
                    item.itemNode.position.y -= 0.005
                }
            }
        }
    }
    
    @IBAction func zAxisChanged(_ sender: UIStepper) {
        if (sender.value == 1) {
            print("up");
            sender.value = 0

            for item in itemArray {
                if item.isSelected {
                    item.itemNode.position.z += 0.005
                }
            }
        } else if (sender.value == -1) {
            print("down")
            sender.value = 0
            
            for item in itemArray {
                if item.isSelected {
                    item.itemNode.position.z -= 0.005
                }
            }
        }
    }
    
    // Lighting Button Items
    @IBOutlet weak var button3StackOutlet: UIStackView!
    
    @IBAction func ambientButtonPressed(_ sender: Any) {
        print("ambient button pressed")
        for item in itemArray {
            if item.isSelected {
                item.itemNode.light?.type = .ambient
            }
        }
    }
    @IBAction func directionalButtonPressed(_ sender: Any) {
        print("directional button pressed")
        for item in itemArray {
            if item.isSelected {
                item.itemNode.light?.type = .directional
            }
        }
    }
    @IBAction func resetButtonPressed(_ sender: Any) {
        print("reset button pressed")
        
        for item in itemArray {
            if item.isSelected {
                item.itemNode.light?.temperature = 5750
                item.itemNode.light?.intensity = 800
                item.itemNode.light?.type = .directional
            }
        }
        
    }
    @IBAction func colorTempChanged(_ sender: UITextField) {
        let value = Int(sender.text!)
        var floatValue = CGFloat(value!)
        
        if floatValue > 40000 {
            floatValue = 40000
            for item in itemArray {
                if item.isSelected {
                    item.itemNode.light?.temperature = floatValue
                }
            }
        }else if floatValue < 0 {
            floatValue = 0
            for item in itemArray {
                if item.isSelected {
                    item.itemNode.light?.temperature = floatValue
                }
            }
        }else {
            for item in itemArray {
                if item.isSelected {
                    item.itemNode.light?.temperature = floatValue
                }
            }
        }
    }
    @IBAction func lumensChanged(_ sender: UITextField) {
        let value = Int(sender.text!)
        var floatValue = CGFloat(value!)
        print("new value: \(value)")
        
        for item in itemArray {
            if item.isSelected {
                item.itemNode.light?.intensity = floatValue
            }
        }
    }
    @IBAction func controlButtonPressed(_ sender: Any) {
        if button1StackOutlet.isHidden {
            hideControls()
            button1StackOutlet.isHidden = false
        }else {
            button1StackOutlet.isHidden = true
        }
    }
    @IBAction func toggleButton2Controls(_ sender: Any) {
        if button2StackOutlet.isHidden {
            hideControls()
            button2StackOutlet.isHidden = false
        }else {
            button2StackOutlet.isHidden = true
        }
    }
    @IBAction func toggleButton3Controls(_ sender: Any) {
        if button3StackOutlet.isHidden {
            hideControls()
            button3StackOutlet.isHidden = false
        }else {
            button3StackOutlet.isHidden = true
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
        mdlNode.castsShadow = true
        let mdlLight = SCNLight()
        mdlLight.type = .directional
        mdlLight.intensity = 800
        mdlLight.temperature = 5750
        mdlLight.castsShadow = true
        mdlNode.light = mdlLight
        
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
        self.itemSelected = indexPath.row
        for item in itemArray {
            item.isSelected = false
        }
        itemArray[indexPath.row].isSelected = true
        userItemView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        selectedIndexPath = indexPath
        userItemView.reloadData()
    }
}
