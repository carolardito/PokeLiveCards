//
//  TableViewController.swift
//  PokeLiveCards
//
//  Created by Carolini Freire Ardito Tavares on 2019-04-22.
//  Copyright © 2019 Carolini Freire Ardito Tavares. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SwiftyJSON

class TableViewController: UITableViewController {
    
    @IBOutlet var table: UITableView!
    
    let ref = Database.database().reference()
    var datafromfirebase: JSON?
    var items: [DataFromDB] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //section that reads info in firebase to display
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            // 2
            var newItems: [DataFromDB] = []
            
            // 3
            for child in snapshot.children {
                // 4
                if let snapshot = child as? DataSnapshot,
                    let groceryItem = DataFromDB(snapshot: snapshot) {
                    newItems.append(groceryItem)
                }
            }
            
            // 5
            self.items = newItems
            self.tableView.reloadData()
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myRow", for: indexPath) as! TableViewCell
        let pokeItem = items[indexPath.row]
        
        cell.pokemonNameCell.text = pokeItem.name


        return cell
    }
 
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let pokeItem = items[indexPath.row]
            pokeItem.ref?.removeValue() //delete from firebase
        }
    }
    
    @IBAction func closeP(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
