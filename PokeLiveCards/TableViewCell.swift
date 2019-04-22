//
//  TableViewCell.swift
//  PokeLiveCards
//
//  Created by Carolini Freire Ardito Tavares on 2019-04-22.
//  Copyright © 2019 Carolini Freire Ardito Tavares. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var pokemonNameCell: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
