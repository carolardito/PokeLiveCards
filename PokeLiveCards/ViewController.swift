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

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var selectedImage : String?//ImageInformation?
    
    // A serial queue for thread safety when modifying SceneKit's scene graph.
    let updateQueue = DispatchQueue(label: "\(Bundle.main.bundleIdentifier!).serialSCNQueue")

    //let images = ["xerneas" : ImageInformation(name: "xerneas", description: "pokemon fada", image: UIImage(named: "xerneas")!)]
    
    private let popupOffset: CGFloat = 440
    
    /*private lazy var contentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "xy10-83")
        return imageView
    }()*/
    
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
    
    private lazy var closedTitleLabel: UILabel = {
        let label = UILabel()
        label.text = self.selectedImage
        label.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        label.textColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        label.textAlignment = .center
        return label
    }()
    
    /*private lazy var reviewsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "reviews")
        return imageView
    }()*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        
        /*layout()
        //popupView.addGestureRecognizer(tapRecognizer)
        popupView.addGestureRecognizer(panRecognizer)*/
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
        
        closedTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(closedTitleLabel)
        closedTitleLabel.leadingAnchor.constraint(equalTo: popupView.leadingAnchor).isActive = true
        closedTitleLabel.trailingAnchor.constraint(equalTo: popupView.trailingAnchor).isActive = true
        closedTitleLabel.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 20).isActive = true
        
        /*reviewsImageView.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(reviewsImageView)
        reviewsImageView.leadingAnchor.constraint(equalTo: popupView.leadingAnchor).isActive = true
        reviewsImageView.trailingAnchor.constraint(equalTo: popupView.trailingAnchor).isActive = true
        reviewsImageView.bottomAnchor.constraint(equalTo: popupView.bottomAnchor).isActive = true
        reviewsImageView.heightAnchor.constraint(equalToConstant: 428).isActive = true*/
    }
    
    private var currentState: State = .closed
    private var transitionAnimator = UIViewPropertyAnimator()
    
    /*private lazy var tapRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer()
        recognizer.addTarget(self, action: #selector(popupViewTapped(recognizer:)))
        return recognizer
    }()
    
    private lazy var panRecognizer: UIPanGestureRecognizer = {
        let recognizer = UIPanGestureRecognizer()*/
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
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Load reference images to look for from "AR Resources" folder
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        
        /*guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "pokemons", bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }*/
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
        //print("carol test = \(String(describing: imageAnchor.referenceImage.name))")
        selectedImage = imageAnchor.referenceImage.name
        //print("carol test variavel = \(selectedImage)")
        //self.performSegue(withIdentifier: "showImgInfo", sender: self)
        // Delegate rendering tasks to our `updateQueue` thread to keep things thread-safe!
        
        layout()
        //popupView.addGestureRecognizer(tapRecognizer)
        popupView.addGestureRecognizer(panRecognizer)
        
        updateQueue.async {
            let physicalWidth = imageAnchor.referenceImage.physicalSize.width //* 100
            let physicalHeight = imageAnchor.referenceImage.physicalSize.height //* 100
            print("physicalWidth = \(physicalWidth)")
            // Create a plane geometry to visualize the initial position of the detected image
            let mainPlane = SCNPlane(width: physicalWidth * 100, height: physicalHeight * 100)
            
            // This bit is important. It helps us create occlusion so virtual things stay hidden behind the detected image
            mainPlane.firstMaterial?.colorBufferWriteMask = .alpha
            
            // Create a SceneKit root node with the plane geometry to attach to the scene graph
            // This node will hold the virtual UI in place
            let mainNode = SCNNode(geometry: mainPlane)
            mainNode.eulerAngles.x = -.pi / 2
            mainNode.renderingOrder = -1
            mainNode.opacity = 1
        
        
            // Pick smallest value to be sure that object fits into the image.
            let finalRatio = [physicalWidth, physicalHeight].min()!
            //mainNode.transform = SCNMatrix4(imageAnchor.transform)
            let appearanceAction = SCNAction.scale(to: CGFloat(finalRatio), duration: 0.4)
            //appearanceAction.timingMode = .easeOut
            //mainNode.scale = SCNVector3Make(1, 1, 1)
            
            // Add the plane visualization to the scene
            node.addChildNode(mainNode)
        
            mainNode.runAction(appearanceAction)
        
            // Perform a quick animation to visualize the plane on which the image was detected.
            // We want to let our users know that the app is responding to the tracked image.
            self.highlightDetection(on: mainNode, width: physicalWidth, height: physicalHeight, completionHandler: {
                
                // Introduce virtual content
                //self.displayDetailView(on: mainNode, xOffset: physicalWidth)
                
                // Animate the WebView to the right
                self.displayWebView(on: mainNode, xOffset: physicalWidth)
                
             })
        }
    }
    
    func highlightDetection(on rootNode: SCNNode, width: CGFloat, height: CGFloat, completionHandler block: @escaping (() -> Void)) {
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
    }
    
    func displayWebView(on rootNode: SCNNode, xOffset: CGFloat) {
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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showImgInfo"{
            if let imageInformationVC = segue.destination as? FindPokeViewController,
                let actualSelectedImage = selectedImage {
                print("actual = \(actualSelectedImage)")
                //imageInformationVC.pokeNameIdentificado = actualSelectedImage.name  // "xerneas"
                //imageInformationVC.imageInformation = actualSelectedImage
                imageInformationVC.pokeNameIdentificado = actualSelectedImage
            }
        }
    }
}
