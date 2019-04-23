//
//  FindPokeViewController.swift
//  PokeLiveCards
//
//  Created by Carolini Freire Ardito Tavares on 2019-04-09.
//  Copyright © 2019 Carolini Freire Ardito Tavares. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Firebase

class FindPokeViewController: UIViewController {

    @IBOutlet weak var pokeNameTxt: UITextField!
    @IBOutlet weak var pokePhoto: UIImageView!
    //-----
    @IBOutlet weak var pokeNameLbl: UILabel!
    
    @IBOutlet weak var attack1Lbl: UILabel!
    @IBOutlet weak var damage1Lbl: UILabel!
    @IBOutlet weak var attack1Info: UITextView!
    
    @IBOutlet weak var attack2Lbl: UILabel!
    @IBOutlet weak var damage2Lbl: UILabel!
    @IBOutlet weak var pokeInfoTxt: UITextView!
    //-----
    
    //let ref = Database.database().reference(withPath: "cards")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (pokeNameIdentificado != nil) {
            pokeNameTxt.text = pokeNameIdentificado
        }
    }
    
    func printPokeInfo(){
        
        self.pokeNameLbl.text = "\(pokemon!.name)"
        self.attack1Lbl.text = "\(pokemon!.attack1)"
        self.damage1Lbl.text = "\(pokemon!.damage1)"
        self.attack1Info.text = "\(pokemon!.attackInfo1)"
        
        self.attack2Lbl.text = "\(pokemon!.attack2)"
        self.damage2Lbl.text = "\(pokemon!.damage2)"
        self.pokeInfoTxt.text = "\(pokemon!.attackInfo2)"
    }
    
    
    @IBAction func findPokeBtn(_ sender: Any) {
        //findInfoPoke()
        
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

//this function goes to api and request information about a specific card
func findInfoPoke(completion : @escaping ()->()){
    //let URL = "https://pokeapi.co/api/v2/pokemon/" + pokeNameTxt.text!
    let URL = "https://api.pokemontcg.io/v1/cards/" + "\(pokeNameIdentificado as! String)"
    print("URL = \(URL)")
    // ALAMOFIRE function: get the data from the website
    Alamofire.request(URL, method: .get, parameters: nil).responseJSON {
        (response) in
        
        // -- put your code below this line
        
        if (response.result.isSuccess) {
            print("awesome, i got a response from the website!")
            print("Response from webiste: " )
            print(response.data)
            
            do {
                //reading JSON result
                let json = try JSON(data:response.data!)
                
                let supertype = json["card"]["supertype"]
                
                //this API has pokemons and trainers. here will create only the correct one
                if (supertype == "Pokémon") {
                
                    print("CAROL - COUNT ATTACKS = \(json["card"]["attacks"].count)")
                    
                    var attacks: [JSON] = []
                    
                    for attack in json["card"]["attacks"] {
                         print("CAROL - ATTACK = \(attack)")
                        
                        attacks.append(attack.1)
                    }
                    
                    print("CAROL - ATTACK/HELP 0 = \(attacks[0])")
                    
                    pokemon = Pokemon(
                        name: "\(json["card"]["name"])",
                        hp: "\(json["card"]["hp"])",
                        attacks: attacks,
                        attack1: "\(json["card"]["attacks"][0]["name"])",
                        damage1: "\(json["card"]["attacks"][0]["damage"])",
                        attackInfo1: "\(json["card"]["attacks"][0]["text"])",
                        attack2: "\(json["card"]["attacks"][1]["name"])",
                        damage2: "\(json["card"]["attacks"][1]["damage"])",
                        attackInfo2: "\(json["card"]["attacks"][1]["text"])",
                        pokeCardImg: "\(pokeNameIdentificado!)"
                    )
                }else{
                    card = CardItem(
                        id: pokeNameIdentificado!,
                        name: "\(json["card"]["name"])",
                        subtype: "\(json["card"]["subtype"])",
                        text: "\(json["card"]["text"])"
                    )
                }
            }
            catch {
                print ("Error while parsing JSON response")
            }
        }
        completion()
    }//End of Json request
    
}
