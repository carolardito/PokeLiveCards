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

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var selectedImage : String?//ImageInformation?
    
    // A serial queue for thread safety when modifying SceneKit's scene graph.
    //let updateQueue = DispatchQueue(label: "\(Bundle.main.bundleIdentifier!).serialSCNQueue")

    //let images = ["xerneas" : ImageInformation(name: "xerneas", description: "pokemon fada", image: UIImage(named: "xerneas")!)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
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
        print("carol test = \(String(describing: imageAnchor.referenceImage.name))")
        selectedImage = imageAnchor.referenceImage.name
        print("carol test variavel = \(selectedImage)")
        //self.performSegue(withIdentifier: "showImgInfo", sender: self)
        // Delegate rendering tasks to our `updateQueue` thread to keep things thread-safe!
        //updateQueue.async {
            let physicalWidth = imageAnchor.referenceImage.physicalSize.width
            let physicalHeight = imageAnchor.referenceImage.physicalSize.height
            
            // Create a plane geometry to visualize the initial position of the detected image
            let mainPlane = SCNPlane(width: physicalWidth, height: physicalHeight)
            
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
            //mainNode.scale = SCNVector3Make(0.001, 0.001, 0.001)
            
            // Add the plane visualization to the scene
            node.addChildNode(mainNode)
        
            mainNode.runAction(appearanceAction)
        
            // Perform a quick animation to visualize the plane on which the image was detected.
            // We want to let our users know that the app is responding to the tracked image.
            /*self.highlightDetection(on: mainNode, width: physicalWidth, height: physicalHeight, completionHandler: {
                
                // Introduce virtual content
                self.displayDetailView(on: mainNode, xOffset: physicalWidth)
                
                // Animate the WebView to the right
                self.displayWebView(on: mainNode, xOffset: physicalWidth)
                
             })*/
        //}
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
