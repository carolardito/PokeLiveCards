//
//  CardItem.swift
//  PokeLiveCards
//
//  Created by Carolini Freire Ardito Tavares on 2019-04-17.
//  Copyright © 2019 Carolini Freire Ardito Tavares. All rights reserved.
//

import Foundation
import SwiftyJSON

//class that stores info from identified trainer card
 class CardItem {
 
     var id: String
     var name: String
     var subtype: String
     var text: String
    
     init(id: String, name: String, subtype: String, text: String) {
         self.id = id
         self.name = name
         self.subtype = subtype
         self.text = text
     }
 }

