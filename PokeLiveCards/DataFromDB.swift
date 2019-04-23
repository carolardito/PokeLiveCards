//
//  DataFromDB.swift
//  PokeLiveCards
//
//  Created by Carolini Freire Ardito Tavares on 2019-04-22.
//  Copyright © 2019 Carolini Freire Ardito Tavares. All rights reserved.
//

import Foundation
import Firebase

struct DataFromDB {
    
    let ref: DatabaseReference?
    let id: String
    let name: String
    
    init(name: String, id: String = "") {
        self.ref = nil
        self.id = id
        self.name = name
    }
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let name = value["name"] as? String else {
                return nil
        }
        
        self.ref = snapshot.ref
        self.id = snapshot.key
        self.name = name
    }
    
    func toAnyObject() -> Any {
        return [
            "name": name
        ]
    }
}
