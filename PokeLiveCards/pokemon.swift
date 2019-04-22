//
//  Pokemon.swift
//  PokeLiveCards
//
//  Created by Carolini Freire Ardito Tavares on 2019-04-18.
//  Copyright © 2019 Carolini Freire Ardito Tavares. All rights reserved.
//

import Foundation
import SwiftyJSON

class Pokemon {
    
    var name: String
    var hp: String
    
    var attack1: String
    var attack2: String?
    
    var attacks: [JSON]
    
    var damage1: String
    var damage2: String?
    
    var attackInfo1: String
    var attackInfo2: String
    
    var pokeCardImg: String
    
    init(name: String, hp: String, attacks: [JSON], attack1: String, damage1: String, attackInfo1: String, attack2: String, damage2: String, attackInfo2: String, pokeCardImg: String) {
        self.name = name
        self.hp = hp
        
        self.attacks = attacks
        
        self.attack1 = attack1
        self.damage1 = damage1
        self.attackInfo1 = attackInfo1
        self.attack2 = attack2
        self.damage2 = damage2
        self.attackInfo2 = attackInfo2
        self.pokeCardImg = pokeCardImg
    }
    
    init(name: String, hp: String, attacks: [JSON], attack1: String, damage1: String, attackInfo1: String, pokeCardImg: String) {
        self.name = name
        self.hp = hp
        
        self.attacks = attacks
        
        self.attack1 = attack1
        self.damage1 = damage1
        self.attackInfo1 = attackInfo1
        self.pokeCardImg = pokeCardImg
        
        self.attack2 = ""
        self.damage2 = ""
        self.attackInfo2 = ""
    }
    
    
    
}
