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

var pokemon: Pokemon?

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
    
    var pokeNameIdentificado : String?
    
    
    //let ref = Database.database().reference(withPath: "cards")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print("Poke name identificado = \(pokeNameIdentificado!)")
        if (pokeNameIdentificado != nil) {
            pokeNameTxt.text = pokeNameIdentificado
            // pokeNameTxt.isEnabled = false
            findInfoPoke()
            //printPokeInfo()
        }else{
            //pokeNameTxt.isEnabled = true
        }
        
        //let carditem = CardItem(name: "Carol")
        //let carditemRef = self.ref.child(text.lowercased())
        
        //carditemRef.setValue(carditem.toAnyObject())
        

        // Do any additional setup after loading the view.
    }
    
    @IBAction func findPokeBtn(_ sender: Any) {
        findInfoPoke()
        
    }
    
    func findInfoPoke(){
        //let URL = "https://pokeapi.co/api/v2/pokemon/" + pokeNameTxt.text!
        let URL = "https://api.pokemontcg.io/v1/cards/" + pokeNameTxt.text!
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
                    let json = try JSON(data:response.data!)
                    
                    //print(json)
                    
                    // PARSING: grab the latitude and longitude
                    //print(json["name"])
                    //print(json)
                    
                    
                    //let currently = json["currently"]["temperature"]
                    //let temp = json["currently"]["temperature"]
                    
                    /*let name = json["name"]
                    let type = json["types"][0]["type"]["name"]
                    let ability = json["abilities"][0]["ability"]["name"]
                    
                    //print("Tempearture: \(temp)")
                    self.pokeInfoTxt.text = "Name: \(name)\nType: \(type)\nAbility 1: \(ability)"*/
                    
                    pokemon = Pokemon(name: "\(json["card"]["name"])", attack1: "\(json["card"]["attacks"][0]["name"])", damage1: "\(json["card"]["attacks"][0]["damage"])", attackInfo1: "\(json["card"]["attacks"][0]["text"])", attack2: "\(json["card"]["attacks"][1]["name"])", damage2: "\(json["card"]["attacks"][1]["damage"])", attackInfo2: "\(json["card"]["attacks"][1]["text"])", pokeCardImg: "\(self.pokeNameIdentificado!)")
                    
                    //pokemon = pokemon1
                    print("CArol = \(pokemon)")
                    
                    /*let name = json["card"]["name"]
                    self.pokeInfoTxt.text = "Name: \(name)"*/
                    
                }
                catch {
                    print ("Error while parsing JSON response")
                }
            }
        }
    }
    
    /*func printPokeInfo(){
        //self.pokePhoto.image = UIImage(named: pokemon!.pokeCardImg)
        
        //let name = json["card"]["name"]
        self.pokeNameLbl.text = "\(pokemon!.name)"
        self.attack1Lbl.text = "\(pokemon!.attack1)"
        self.damage1Lbl.text = "\(pokemon!.damage1)"
        self.attack1Info.text = "\(pokemon!.attackInfo1)"
        
        self.attack2Lbl.text = "\(pokemon!.attack2)"
        self.damage2Lbl.text = "\(pokemon!.damage2)"
        self.pokeInfoTxt.text = "\(pokemon!.attackInfo2)"
    }*/
    

    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
