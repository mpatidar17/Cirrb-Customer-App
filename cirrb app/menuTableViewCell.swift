//
//  menuTableViewCell.swift
//  Aqua
//
//  Created by Harsha Cuttari on 12/29/16.
//  Copyright © 2016 Harsha Cuttari. All rights reserved.
//

import UIKit

class menuTableViewCell: UITableViewCell {
    @IBOutlet weak var menuNameLabel: UILabel!
    
    @IBOutlet weak var menuIconImageView: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
