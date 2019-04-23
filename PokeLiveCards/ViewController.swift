//
//  ViewController.swift
//  PokeLiveCards
//
//  Created by Carolini Freire Ardito Tavares on 2019-04-07.
//  Copyright © 2019 Carolini Freire Ardito Tavares. All rights reserved.
//  bottom menu based =  https://github.com/nathangitter/interactive-animations/commits/master

import UIKit
import SceneKit
import ARKit
import UIKit.UIGestureRecognizerSubclass
import FirebaseDatabase

var pokemon: Pokemon?
var card: CardItem?
var pokeNameIdentificado : String?

//state from floating bottom menu
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
    
    let ref = Database.database().reference()
    
    var selectedImage : String?//ImageInformation?
    private var imageConfiguration: ARImageTrackingConfiguration?
    private var worldConfiguration: ARWorldTrackingConfiguration?
    
    private let popupOffset: CGFloat = 380 //this is the size of the floating menu
    
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
        //label.text = pokemon!.name
        label.font = UIFont.systemFont(ofSize: 24, weight: UIFont.Weight.medium)
        label.textColor = .orange
        label.textAlignment = .center
        return label
    }()
    
    private lazy var pokemonHPLabel: UILabel = {
        let label = UILabel()
        //label.text = "HP: \(pokemon!.hp)"
        label.font = UIFont.systemFont(ofSize: 22, weight: UIFont.Weight.medium)
        label.textColor = .red
        label.textAlignment = .center
        return label
    }()
    
    private lazy var attack1Label: UILabel = {
        let label = UILabel()
        //label.text = pokemon!.attack1
        label.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        label.textColor = .black// #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var attack2Label: UILabel = {
        let label = UILabel()
        //label.text = pokemon!.attack2
        label.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        label.textColor = .black//#colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var damage1Label: UILabel = {
        let label = UILabel()
        //label.text = pokemon!.damage1
        label.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        label.textColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var damage2Label: UILabel = {
        let label = UILabel()
        //label.text = pokemon!.damage2
        label.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        label.textColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var attackInfo1Label: UILabel = {
        let label = UILabel()
        //print("texto \(pokemon!.attackInfo1)")
        //label.text = pokemon!.attackInfo1
        label.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        label.textColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        label.textAlignment = .center
        label.numberOfLines = 3
        return label
    }()
    
    private lazy var attackInfo2Label: UILabel = {
        let label = UILabel()
        //label.text = pokemon!.attackInfo2
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
    
    //function that will create runtime the labels
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
        
        if (pokemon != nil) {
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
            
            pokemonHPLabel.isHidden = false
            damage1Label.isHidden = false
            
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
        }else{
            pokemonHPLabel.isHidden = true
            damage1Label.isHidden = true
            attack2Label.isHidden = true
            damage2Label.isHidden = true
            attackInfo2Label.isHidden = true
            
            pokemonNameLabel.translatesAutoresizingMaskIntoConstraints = false
            pokemonNameLabel.text = card!.name
            popupView.addSubview(pokemonNameLabel)
            pokemonNameLabel.leadingAnchor.constraint(equalTo: popupView.leadingAnchor).isActive = true
            pokemonNameLabel.trailingAnchor.constraint(equalTo: popupView.trailingAnchor).isActive = true
            pokemonNameLabel.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 20).isActive = true
            
            attack1Label.translatesAutoresizingMaskIntoConstraints = false
            attack1Label.text = "\(card!.subtype)"
            popupView.addSubview(attack1Label)
            attack1Label.leftAnchor.constraint(equalTo: popupView.leftAnchor, constant: 5).isActive = true
            attack1Label.topAnchor.constraint(equalTo: pokemonNameLabel.topAnchor, constant: 50).isActive = true
            
            attackInfo1Label.translatesAutoresizingMaskIntoConstraints = false
            attackInfo1Label.text = "\(card!.text)"
            popupView.addSubview(attackInfo1Label)
            attackInfo1Label.centerXAnchor.constraint(equalTo: popupView.centerXAnchor).isActive = true
            attackInfo1Label.leadingAnchor.constraint(equalTo: popupView.leadingAnchor).isActive = true
            attackInfo1Label.trailingAnchor.constraint(equalTo: popupView.trailingAnchor).isActive = true
            attackInfo1Label.topAnchor.constraint(equalTo: attack1Label.topAnchor, constant: 30).isActive = true
            attackInfo1Label.contentMode = .scaleToFill
            attackInfo1Label.adjustsFontSizeToFitWidth = true
        }
        
        //check if pokemon.card already exists inside database and hide button
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
        wishListButton.topAnchor.constraint(equalTo: attackInfo1Label.bottomAnchor, constant: 150).isActive = true
    }
    
    //add to wishlist
    @objc func buttonTouched(_ button: UIButton) {
        print("boop")
        if pokemon != nil {
            ref.child(pokeNameIdentificado!).setValue(["name": pokemon!.name, "id": pokeNameIdentificado!])
        }else{
            ref.child(pokeNameIdentificado!).setValue(["name": card!.name, "id": pokeNameIdentificado!])
        }
        self.wishListButton.isHidden = true
    }
    
    private var currentState: State = .closed 
    private var transitionAnimator = UIViewPropertyAnimator()
    
    //finger movement
    private lazy var panRecognizer: InstantPanGestureRecognizer = {
        let recognizer = InstantPanGestureRecognizer()
        recognizer.addTarget(self, action: #selector(popupViewPanned(recognizer:)))
        return recognizer
    }()
    
    //animation to hide or open bottom menu
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
    
    //func that will recognize the image
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        
        selectedImage = imageAnchor.referenceImage.name
        
        pokeNameIdentificado = selectedImage
        
        pokemon = nil
        card = nil
        
        //go to api
        findInfoPoke(completion: {
            self.layout()
            self.popupView.addGestureRecognizer(self.panRecognizer)
        })
    }
    
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
