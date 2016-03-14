//
//  DueDateViewCell.swift
//  buho-Mobile
//
//  Created by Rodrigo Astorga on 3/14/16.
//  Copyright © 2016 Rodrigo Astorga. All rights reserved.
//

import UIKit

class DueDateViewCell: UITableViewCell {

    @IBOutlet weak var labelDueDate: UILabel!
    @IBOutlet weak var imageViewTime: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
