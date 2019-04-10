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

struct ImageInformation {
    let name: String
    let description: String
    let image: UIImage
}

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    private var planeNode: SCNNode?
    private var imageNode: SCNNode?
    private var animationInfo: AnimationInfo?
    
    var selectedImage : String?//ImageInformation?
    
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
        self.performSegue(withIdentifier: "showImgInfo", sender: self)
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
