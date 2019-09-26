//
//  SortOrderTableViewCell.swift
//  MovieBrower
//
//  Created by sreejith on 26/09/19.
//  Copyright © 2019 sreejith. All rights reserved.
//

import UIKit

class SortOrderTableViewCell: UITableViewCell {

    @IBOutlet weak var sortOrderTitle: UILabel!
    @IBOutlet weak var tickImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
