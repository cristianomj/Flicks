//
//  FlickCell.swift
//  Flicks
//
//  Created by Cristiano Miranda on 2/3/16.
//  Copyright © 2016 Cristiano Miranda. All rights reserved.
//

import UIKit

class FlickCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var posterView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
