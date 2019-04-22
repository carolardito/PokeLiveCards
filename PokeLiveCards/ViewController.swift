//
//  ViewController.swift
//  PokeLiveCards
//
//  Created by Carolini Freire Ardito Tavares on 2019-04-07.
//  Copyright © 2019 Carolini Freire Ardito Tavares. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import UIKit.UIGestureRecognizerSubclass
import FirebaseDatabase

var pokemon: Pokemon?
var pokeNameIdentificado : String?

private enum State {
    case closed
    case open
}

extension State {
    var opposite: State {
        switch self {
        case .open: return .closed
        case .closed: return .open
        }
    }
}

extension SCNNode {
    
    public class func allNodes(from file: String) -> [SCNNode] {
        var nodesInFile = [SCNNode]()
        do {
            guard let sceneURL = Bundle.main.path(forResource: file, ofType: "gif") else {
                print("Could not find scene file \(file)")
                return nodesInFile
            }
            
            //SCNScene(named: file+".dae")
            
            let objScene = try SCNScene(named: file+".gif")/*SCNScene(url: sceneURL as URL, options: [SCNSceneSource.LoadingOption.animationImportPolicy: SCNSceneSource.AnimationImportPolicy.doNotPlay])*/
            objScene!.rootNode.enumerateChildNodes({ (node, _) in
                nodesInFile.append(node)
            })
        } catch {}
        return nodesInFile
    }
}

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    let ref = Database.database().reference()
    
    var selectedImage : String?//ImageInformation?
    private var imageConfiguration: ARImageTrackingConfiguration?
    private var worldConfiguration: ARWorldTrackingConfiguration?
    
    // A serial queue for thread safety when modifying SceneKit's scene graph.
    let updateQueue = DispatchQueue(label: "\(Bundle.main.bundleIdentifier!).serialSCNQueue")

    //let images = ["xerneas" : ImageInformation(name: "xerneas", description: "pokemon fada", image: UIImage(named: "xerneas")!)]
    
    private let popupOffset: CGFloat = 440
    
    private lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        return view
    }()
    
    private lazy var popupView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 10
        return view
    }()
    
    private lazy var pokemonNameLabel: UILabel = {
        let label = UILabel()
        label.text = pokemon!.name
        label.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.medium)
        label.textColor = .orange
        label.textAlignment = .center
        return label
    }()
    
    private lazy var pokemonHPLabel: UILabel = {
        let label = UILabel()
        label.text = "HP: \(pokemon!.hp)"
        label.font = UIFont.systemFont(ofSize: 22, weight: UIFont.Weight.medium)
        label.textColor = .red
        label.textAlignment = .center
        return label
    }()
    
    /*private lazy var attackLabel: UILabel = {
        let label = UILabel()
        label.text = "Attacks:"
        label.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.medium)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()*/
    
    private lazy var attack1Label: UILabel = {
        let label = UILabel()
        label.text = pokemon!.attack1
        label.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        label.textColor = .black// #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var attack2Label: UILabel = {
        let label = UILabel()
        label.text = pokemon!.attack2
        label.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        label.textColor = .black//#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var damage1Label: UILabel = {
        let label = UILabel()
        label.text = pokemon!.damage1
        label.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        label.textColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var damage2Label: UILabel = {
        let label = UILabel()
        label.text = pokemon!.damage2
        label.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        label.textColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var attackInfo1Label: UILabel = {
        let label = UILabel()
        print("texto \(pokemon!.attackInfo1)")
        label.text = pokemon!.attackInfo1
        label.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        label.textColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        label.textAlignment = .center
        label.numberOfLines = 3
        return label
    }()
    
    private lazy var attackInfo2Label: UILabel = {
        let label = UILabel()
        label.text = pokemon!.attackInfo2
        label.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        label.textColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        label.textAlignment = .center
        label.numberOfLines = 3
        return label
    }()
    
    private lazy var wishListButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add to wishlist", for: .normal)
        button.backgroundColor = .blue
        button.tintColor = .white
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        
        let scene = SCNScene()
        sceneView.scene = scene
        
        //setupObjectDetection()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private var bottomConstraint = NSLayoutConstraint()
    
    private func layout() {
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayView)
        overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        overlayView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        popupView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(popupView)
        popupView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        popupView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomConstraint = popupView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: popupOffset)
        bottomConstraint.isActive = true
        popupView.heightAnchor.constraint(equalToConstant: 500).isActive = true
        
        pokemonNameLabel.translatesAutoresizingMaskIntoConstraints = false
        pokemonNameLabel.text = pokemon!.name
        popupView.addSubview(pokemonNameLabel)
        pokemonNameLabel.leadingAnchor.constraint(equalTo: popupView.leadingAnchor).isActive = true
        pokemonNameLabel.trailingAnchor.constraint(equalTo: popupView.trailingAnchor).isActive = true
        pokemonNameLabel.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 20).isActive = true
        
        pokemonHPLabel.translatesAutoresizingMaskIntoConstraints = false
        pokemonHPLabel.text = pokemon!.hp
        popupView.addSubview(pokemonHPLabel)
        pokemonHPLabel.leadingAnchor.constraint(equalTo: popupView.leadingAnchor).isActive = true
        pokemonHPLabel.trailingAnchor.constraint(equalTo: popupView.trailingAnchor).isActive = true
        pokemonHPLabel.topAnchor.constraint(equalTo: pokemonNameLabel.topAnchor, constant: 25).isActive = true
        
        /*attackLabel.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(attackLabel)
        attackLabel.leftAnchor.constraint(equalTo: popupView.leftAnchor, constant: 5).isActive = true
        attackLabel.topAnchor.constraint(equalTo: pokemonNameLabel.topAnchor, constant: 50).isActive = true*/
        
        attack1Label.translatesAutoresizingMaskIntoConstraints = false
        attack1Label.text = "\(pokemon!.attacks[0]["name"])"
        popupView.addSubview(attack1Label)
        attack1Label.leftAnchor.constraint(equalTo: popupView.leftAnchor, constant: 5).isActive = true
        attack1Label.topAnchor.constraint(equalTo: pokemonHPLabel.topAnchor, constant: 50).isActive = true
        
        damage1Label.translatesAutoresizingMaskIntoConstraints = false
        damage1Label.text = "\(pokemon!.attacks[0]["damage"])"
        popupView.addSubview(damage1Label)
        damage1Label.rightAnchor.constraint(equalTo: popupView.rightAnchor).isActive = true
        damage1Label.topAnchor.constraint(equalTo: pokemonHPLabel.topAnchor, constant: 50).isActive = true
        
        attackInfo1Label.translatesAutoresizingMaskIntoConstraints = false
        attackInfo1Label.text = "\(pokemon!.attacks[0]["text"])"
        popupView.addSubview(attackInfo1Label)
        attackInfo1Label.centerXAnchor.constraint(equalTo: popupView.centerXAnchor).isActive = true
        attackInfo1Label.leadingAnchor.constraint(equalTo: popupView.leadingAnchor).isActive = true
        attackInfo1Label.trailingAnchor.constraint(equalTo: popupView.trailingAnchor).isActive = true
        attackInfo1Label.topAnchor.constraint(equalTo: attack1Label.topAnchor, constant: 30).isActive = true
        attackInfo1Label.rightAnchor.constraint(equalTo: damage1Label.rightAnchor, constant: 10).isActive = true
        attackInfo1Label.contentMode = .scaleToFill
        attackInfo1Label.adjustsFontSizeToFitWidth = true
        
        
        if (pokemon!.attacks.count == 2) {
            attack2Label.isHidden = false
            attack2Label.translatesAutoresizingMaskIntoConstraints = false
            attack2Label.text = "\(pokemon!.attacks[1]["name"])"
            //attack2Label.text = pokemon!.attack2
            popupView.addSubview(attack2Label)
            attack2Label.leftAnchor.constraint(equalTo: popupView.leftAnchor, constant: 5).isActive = true
            attack2Label.topAnchor.constraint(equalTo: attackInfo1Label.bottomAnchor, constant: 40).isActive = true
            
            damage2Label.isHidden = false
            damage2Label.translatesAutoresizingMaskIntoConstraints = false
            damage2Label.text = "\(pokemon!.attacks[1]["damage"])"
            popupView.addSubview(damage2Label)
            damage2Label.rightAnchor.constraint(equalTo: popupView.rightAnchor).isActive = true
            damage2Label.topAnchor.constraint(equalTo: attackInfo1Label.bottomAnchor, constant: 40).isActive = true
            
            attackInfo2Label.isHidden = false
            attackInfo2Label.translatesAutoresizingMaskIntoConstraints = false
            attackInfo2Label.text = "\(pokemon!.attacks[1]["text"])"
            popupView.addSubview(attackInfo2Label)
            attackInfo2Label.centerXAnchor.constraint(equalTo: popupView.centerXAnchor).isActive = true
            attackInfo2Label.leadingAnchor.constraint(equalTo: popupView.leadingAnchor).isActive = true
            attackInfo2Label.trailingAnchor.constraint(equalTo: popupView.trailingAnchor).isActive = true
            attackInfo2Label.topAnchor.constraint(equalTo: attack2Label.topAnchor, constant: 30).isActive = true
            attackInfo2Label.rightAnchor.constraint(equalTo: damage2Label.rightAnchor, constant: 10).isActive = true
            attackInfo2Label.contentMode = .scaleToFill
            attackInfo2Label.adjustsFontSizeToFitWidth = true
        }else{
            attack2Label.isHidden = true
            damage2Label.isHidden = true
            attackInfo2Label.isHidden = true
        }
        
        //var dataFromDB: [String: Any] = [:]
        var exists = false
        ref.child(pokeNameIdentificado!).observeSingleEvent(of: .value){ (snapshot) in
            let dataFromDB = snapshot.value as? [String: Any]
            
            print("CAROL DB = \(dataFromDB)")
            //print("CAROL DB code = \(dataFromDB!["code"])")
            
            if dataFromDB != nil {
                exists = true
                self.wishListButton.isHidden = true
            }else{
                self.wishListButton.isHidden = false
            }
        }
        
        wishListButton.translatesAutoresizingMaskIntoConstraints = false
        wishListButton.addTarget(self, action: #selector(buttonTouched(_:)), for: .touchDown)
        popupView.addSubview(wishListButton)
        wishListButton.centerXAnchor.constraint(equalTo: popupView.centerXAnchor).isActive = true
        wishListButton.topAnchor.constraint(equalTo: attackInfo2Label.bottomAnchor, constant: 40).isActive = true
    }
    
    
    @objc func buttonTouched(_ button: UIButton) {
        print("boop")
        ref.child(pokeNameIdentificado!).setValue(["name": pokemon!.name])
        self.wishListButton.isHidden = true
    }
    
    private var currentState: State = .closed 
    private var transitionAnimator = UIViewPropertyAnimator()
    
    private lazy var panRecognizer: InstantPanGestureRecognizer = {
        let recognizer = InstantPanGestureRecognizer()
        recognizer.addTarget(self, action: #selector(popupViewPanned(recognizer:)))
        return recognizer
    }()
    
    private func animateTransitionIfNeeded(to state: State, duration: TimeInterval) {
        if transitionAnimator.isRunning { return }
        transitionAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1, animations: {
            switch state {
            case .open:
                self.bottomConstraint.constant = 0
                self.popupView.layer.cornerRadius = 20
                self.overlayView.alpha = 0.5
            case .closed:
                self.bottomConstraint.constant = self.popupOffset
                self.popupView.layer.cornerRadius = 0
                self.overlayView.alpha = 0
            }
            self.view.layoutIfNeeded()
        })
        transitionAnimator.addCompletion { position in
            switch position {
            case .start:
                self.currentState = state.opposite
            case .end:
                self.currentState = state
            case .current:
                ()
            }
            switch self.currentState {
            case .open:
                self.bottomConstraint.constant = 0
            case .closed:
                self.bottomConstraint.constant = self.popupOffset
            }
        }
        transitionAnimator.startAnimation()
    }
    
    class InstantPanGestureRecognizer: UIPanGestureRecognizer {
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
            if (self.state == UIGestureRecognizer.State.began) { return }
            super.touchesBegan(touches, with: event)
            self.state = UIGestureRecognizer.State.began
        }
        
    }
    
    @objc private func popupViewPanned(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            animateTransitionIfNeeded(to: currentState.opposite, duration: 1)
            transitionAnimator.pauseAnimation()
        case .changed:
            let translation = recognizer.translation(in: popupView)
            var fraction = -translation.y / popupOffset
            if currentState == .open { fraction *= -1 }
            transitionAnimator.fractionComplete = fraction
        case .ended:
            transitionAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        default:
            ()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let configuration = worldConfiguration {
            sceneView.debugOptions = .showFeaturePoints
            sceneView.session.run(configuration)
        }
        
        // Load reference images to look for from "AR Resources" folder
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Add previously loaded images to ARScene configuration as detectionImages
        configuration.detectionImages = referenceImages
        //configuration.trackingImages = referenceImages
        configuration.maximumNumberOfTrackedImages = 1
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        
        //imageConfiguration?.trackingImages = referenceImages
        
        selectedImage = imageAnchor.referenceImage.name
        
        pokeNameIdentificado = selectedImage
        
        pokemon = nil
        
        /*node.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }*/
        
        /*self.sceneView.scene.rootNode.enumerateChildNodes { (existingNode, _) in
            existingNode.removeFromParentNode()
        }*/
        
        findInfoPoke(completion: {
            self.layout()
            self.popupView.addGestureRecognizer(self.panRecognizer)
            
            /*let size = imageAnchor.referenceImage.physicalSize
            if let videoNode = self.makeDinosaurVideo(size: size) {
                node.addChildNode(videoNode)
                node.opacity = 1
                
                //addCar()
            }*/
            //self.addCar()
            
            //if let camera = sceneView.session.currentFrame?.camera {
                //didInitializeScene = true
                /*var translation = matrix_identity_float4x4
                translation.columns.3.z = -1.0
                //let transform = camera.transform * translation
            let position = SCNVector3Make((node.position.x) + 2,
                                          (node.position.y) + 4,
                                          (node.position.z) - 2)//SCNVector3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
                self.addSphere(position: position)*/
            //}
            /*
            let plane = SCNPlane(width: 2, height: 2)
            
            let bundleURL = Bundle.main.url(forResource: "xerneas", withExtension: "gif")
            let animation : CAKeyframeAnimation = self.createGIFAnimation(url: bundleURL!)!
            let layer = CALayer()
            layer.bounds = CGRect(x: 0, y: 0, width: 900, height: 900)
            
            layer.add(animation, forKey: "contents")
            let tempView = UIView.init(frame: CGRect(x: 0, y: 0, width: 900, height: 900))
            tempView.layer.bounds = CGRect(x: -450, y: -450, width: tempView.frame.size.width, height: tempView.frame.size.height)
            tempView.layer.addSublayer(layer)
            
            let newMaterial = SCNMaterial()
            newMaterial.isDoubleSided = true
            newMaterial.diffuse.contents = tempView.layer
            plane.materials = [newMaterial]
            let nodeX = SCNNode(geometry: plane)
            nodeX.name = "xerneas"
            let gifImagePosition = SCNVector3Make((node.position.x) + 2,
                                                  (node.position.y) + 4,
                                                  (node.position.z) - 2)
            nodeX.position = gifImagePosition
            node.addChildNode(nodeX)
            */
        })
        
        /*if let help = addCar(){
            node.addChildNode(help)
            node.opacity = 1
        }*/
        
        /*let size = imageAnchor.referenceImage.physicalSize
        if let videoNode = makeDinosaurVideo(size: size) {
            node.addChildNode(videoNode)
            node.opacity = 1
            
            //addCar()
        }*/
    }
    
    /*func addSphere(position: SCNVector3) {
        guard let scene = self.sceneView else { return }
        
        let containerNode = SCNNode()
        let nodesInFile = SCNNode.allNodes(from: "xerneas")
        
        nodesInFile.forEach { (node) in
            containerNode.addChildNode(node)
        }
        
        containerNode.position = position
        scene.scene.rootNode.addChildNode(containerNode)
    }*/
    
    /*func createGIFAnimation(url:URL) -> CAKeyframeAnimation? {
        
        guard let src = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        let frameCount = CGImageSourceGetCount(src)
        
        // Total loop time
        var time : Float = 0
        
        // Arrays
        var framesArray = [AnyObject]()
        var tempTimesArray = [NSNumber]()
        
        // Loop
        for i in 0..<frameCount {
            
            // Frame default duration
            var frameDuration : Float = 0.1;
            
            let cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(src, i, nil)
            guard let framePrpoerties = cfFrameProperties as? [String:AnyObject] else {return nil}
            guard let gifProperties = framePrpoerties[kCGImagePropertyGIFDictionary as String] as? [String:AnyObject]
                else { return nil }
            
            // Use kCGImagePropertyGIFUnclampedDelayTime or kCGImagePropertyGIFDelayTime
            if let delayTimeUnclampedProp = gifProperties[kCGImagePropertyGIFUnclampedDelayTime as String] as? NSNumber {
                frameDuration = delayTimeUnclampedProp.floatValue
            } else {
                if let delayTimeProp = gifProperties[kCGImagePropertyGIFDelayTime as String] as? NSNumber {
                    frameDuration = delayTimeProp.floatValue
                }
            }
            
            // Make sure its not too small
            if frameDuration < 0.011 {
                frameDuration = 0.100;
            }
            
            // Add frame to array of frames
            if let frame = CGImageSourceCreateImageAtIndex(src, i, nil) {
                tempTimesArray.append(NSNumber(value: frameDuration))
                framesArray.append(frame)
            }
            
            // Compile total loop time
            time = time + frameDuration
        }
        
        var timesArray = [NSNumber]()
        var base : Float = 0
        for duration in tempTimesArray {
            timesArray.append(NSNumber(value: base))
            base += ( duration.floatValue / time )
        }
        
        // From documentation of 'CAKeyframeAnimation':
        // the first value in the array must be 0.0 and the last value must be 1.0.
        // The array should have one more entry than appears in the values array.
        // For example, if there are two values, there should be three key times.
        timesArray.append(NSNumber(value: 1.0))
        
        // Create animation
        let animation = CAKeyframeAnimation(keyPath: "contents")
        
        animation.beginTime = AVCoreAnimationBeginTimeAtZero
        animation.duration = CFTimeInterval(time)
        animation.repeatCount = Float.greatestFiniteMagnitude;
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.values = framesArray
        animation.keyTimes = timesArray
        //animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.calculationMode = CAAnimationCalculationMode.discrete
        
        return animation;
    }*/
    
    /*func addCar(x: Float = 0, y: Float = 0, z: Float = -0.5) {
        guard let carScene = SCNScene(named: "plane.scn") else { return }
        let carNode = SCNNode()
        let carSceneChildNodes = carScene.rootNode.childNodes
        for childNode in carSceneChildNodes {
            carNode.addChildNode(childNode)
        }
        carNode.position = SCNVector3(x, y, z)
        carNode.scale = SCNVector3(0.5, 0.5, 0.5)
        sceneView.scene.rootNode.addChildNode(carNode)
        //return carNode
    }*/
    
    /*func existingWishList() -> DarwinBoolean {
        var dataFromDB: [String: Any] = [:]
        ref.childByAutoId().observeSingleEvent(of: .value){ (snapshot) in
            dataFromDB = (snapshot.value as?  [String: Any])!
            
        }
        
        if pokeNameIdentificado = dataFromDB["code"] as! String {
            return true
        }
        
        return false
        
    }*/
    
    private func makeDinosaurVideo(size: CGSize) -> SCNNode? {
        sceneView.backgroundColor = .clear
        //sceneView.scaleMode = .aspectFit
        
        // 1
        guard let videoURL = Bundle.main.url(forResource: "model"/*"dinosaur"*/,
                                             withExtension: "dae"/*"mp4"*/) else {
                                                return nil
        }
        
        // 2
        let avPlayerItem = AVPlayerItem(url: videoURL)
        let avPlayer = AVPlayer(playerItem: avPlayerItem)
        //avPlayer.play()
        
        // 3
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: nil,
            queue: nil) { notification in
                avPlayer.seek(to: .zero)
                avPlayer.play()
        }
        
        // 4
        let avMaterial = SCNMaterial()
        //let animation = SCNAnimation(named: "plane.scn")
        //avMaterial.diffuse.addAnimation(animation, forKey: "xerneas")
        avMaterial.diffuse.contents = avPlayer
        
        // 5
        let videoPlane = SCNPlane(width: size.width, height: size.height)
        videoPlane.materials = [avMaterial]
        
        // 6
        let videoNode = SCNNode(geometry: videoPlane)
        videoNode.eulerAngles.x = -.pi / 2
        return videoNode
    }
    
    private func setupImageDetection() {
        imageConfiguration = ARImageTrackingConfiguration()
        
        guard let referenceImages = ARReferenceImage.referenceImages(
            inGroupNamed: "AR Resources", bundle: nil) else {
                fatalError("Missing expected asset catalog resources.")
        }
        imageConfiguration?.trackingImages = referenceImages
    }
    
    private func setupObjectDetection() {
        worldConfiguration = ARWorldTrackingConfiguration()
        
        guard let referenceObjects = ARReferenceObject.referenceObjects(
            inGroupNamed: "AR Objects", bundle: nil) else {
                fatalError("Missing expected asset catalog resources.")
        }
        
        worldConfiguration?.detectionObjects = referenceObjects
        
        guard let referenceImages = ARReferenceImage.referenceImages(
            inGroupNamed: "AR Resources", bundle: nil) else {
                fatalError("Missing expected asset catalog resources.")
        }
        worldConfiguration?.detectionImages = referenceImages
    }
    
    /*func highlightDetection(on rootNode: SCNNode, width: CGFloat, height: CGFloat, completionHandler block: @escaping (() -> Void)) {
        let planeNode = SCNNode(geometry: SCNPlane(width: width, height: height))
        planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        planeNode.position.z += 0.1
        planeNode.opacity = 0
        
        rootNode.addChildNode(planeNode)
        planeNode.runAction(self.imageHighlightAction) {
            block()
        }
    }
    
    var imageHighlightAction: SCNAction {
        return .sequence([
            .wait(duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOpacity(to: 0.15, duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOut(duration: 0.5),
            .removeFromParentNode()
            ])
    }*/
    
    /*func displayWebView(on rootNode: SCNNode, xOffset: CGFloat) {
        // Xcode yells at us about the deprecation of UIWebView in iOS 12.0, but there is currently
        // a bug that does now allow us to use a WKWebView as a texture for our webViewNode
        // Note that UIWebViews should only be instantiated on the main thread!
        DispatchQueue.main.async {
            let request = URLRequest(url: URL(string: "https://www.worldwildlife.org/species/african-elephant#overview")!)
            let webView = UIWebView(frame: CGRect(x: 0, y: 0, width: 400, height: 672))
            webView.loadRequest(request)
            
            let webViewPlane = SCNPlane(width: xOffset, height: xOffset * 1.4)
            webViewPlane.cornerRadius = 0.25
            
            let webViewNode = SCNNode(geometry: webViewPlane)
            webViewNode.geometry?.firstMaterial?.diffuse.contents = webView
            webViewNode.position.z -= 0.5
            webViewNode.opacity = 0
            
            rootNode.addChildNode(webViewNode)
            webViewNode.runAction(.sequence([
                .wait(duration: 3.0),
                .fadeOpacity(to: 1.0, duration: 1.5),
                .moveBy(x: xOffset * 1.1, y: 0, z: -0.05, duration: 1.5),
                .moveBy(x: 0, y: 0, z: -0.05, duration: 0.2)
                ])
            )
        }
    }
    
    func displayDetailView(on rootNode: SCNNode, xOffset: CGFloat) {
        let detailPlane = SCNPlane(width: xOffset, height: xOffset * 1.4)
        detailPlane.cornerRadius = 0.25
        
        let detailNode = SCNNode(geometry: detailPlane)
        detailNode.geometry?.firstMaterial?.diffuse.contents = SKScene(fileNamed: "DetailScene")
        
        // Due to the origin of the iOS coordinate system, SCNMaterial's content appears upside down, so flip the y-axis.
        detailNode.geometry?.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
        detailNode.position.z -= 0.5
        detailNode.opacity = 0
        
        rootNode.addChildNode(detailNode)
        detailNode.runAction(.sequence([
            .wait(duration: 1.0),
            .fadeOpacity(to: 1.0, duration: 1.5),
            .moveBy(x: xOffset * -1.1, y: 0, z: -0.05, duration: 1.5),
            .moveBy(x: 0, y: 0, z: -0.05, duration: 0.2)
            ])
        )
    }*/
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showImgInfo"{
            if let imageInformationVC = segue.destination as? FindPokeViewController,
                let actualSelectedImage = selectedImage {
                print("actual = \(actualSelectedImage)")
                //imageInformationVC.pokeNameIdentificado = actualSelectedImage.name  // "xerneas"
                //imageInformationVC.imageInformation = actualSelectedImage
                //imageInformationVC.pokeNameIdentificado = actualSelectedImage
                pokeNameIdentificado = actualSelectedImage
            }
        }
    }
}
