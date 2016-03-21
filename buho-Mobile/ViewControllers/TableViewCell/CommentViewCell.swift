//
//  CommentViewCell.swift
//  buho-Mobile
//
//  Created by Rodrigo Astorga on 3/21/16.
//  Copyright © 2016 Rodrigo Astorga. All rights reserved.
//

import UIKit

class CommentViewCell: UITableViewCell {
    
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var labelApproved: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        labelApproved.layer.cornerRadius = 5
        labelApproved.layer.borderColor = UIColor(red: 82/255, green: 82/255, blue: 97/255, alpha: 1).CGColor
        labelApproved.layer.borderWidth = 1.0
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
