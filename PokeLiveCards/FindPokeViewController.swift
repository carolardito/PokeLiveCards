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

class FindPokeViewController: UIViewController {

    @IBOutlet weak var pokeNameTxt: UITextField!
    @IBOutlet weak var pokeInfoTxt: UITextView!
    @IBOutlet weak var pokePhoto: UIImageView!
    
    var pokeNameIdentificado : String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print("Poke name identificado = \(pokeNameIdentificado!)")
        if (pokeNameIdentificado != nil) {
            pokeNameTxt.text = pokeNameIdentificado
             pokeNameTxt.isEnabled = false
            findInfoPoke()
        }else{
            //pokeNameTxt.isEnabled = true
        }
        

        // Do any additional setup after loading the view.
    }
    
    @IBAction func findPokeBtn(_ sender: Any) {
        findInfoPoke()
    }
    
    func findInfoPoke(){
        let URL = "https://pokeapi.co/api/v2/pokemon/" + pokeNameTxt.text!
        
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
                    print(json["name"])
                    //print(json)
                    
                    
                    //let currently = json["currently"]["temperature"]
                    //let temp = json["currently"]["temperature"]
                    
                    let name = json["name"]
                    let type = json["types"][0]["type"]["name"]
                    let ability = json["abilities"][0]["ability"]["name"]
                    
                    //print("Tempearture: \(temp)")
                    self.pokeInfoTxt.text = "Name: \(name)\nType: \(type)\nAbility 1: \(ability)"
                    
                    
                    //self.pokePhoto.image = UIImage(photo)
                    
                }
                catch {
                    print ("Error while parsing JSON response")
                }
            }
        }
    }
    

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
