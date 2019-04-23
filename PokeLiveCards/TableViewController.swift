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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        /*ref.observe(.value) { snapshot in
            for child in snapshot.children {
                let help = child as? JSON
                print("CAROL DB child = \(child)")
                print("CAROL DB help= \(help)")
                //self.datafromfirebase.append(child)
            }
        }*/
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
            // Delete the row from the data source
            //tableView.deleteRows(at: [indexPath], with: .fade)
            let pokeItem = items[indexPath.row]
            pokeItem.ref?.removeValue()
            //tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func closeP(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
