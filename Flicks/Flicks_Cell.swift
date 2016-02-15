//
//  Flicks_Cell.swift
//  Flicks
//
//  Created by Cristiano Miranda on 2/7/16.
//  Copyright © 2016 Cristiano Miranda. All rights reserved.
//

import UIKit

class Flicks_Cell: UICollectionViewCell {
    @IBOutlet weak var posterView: UIImageView!
    
    override func prepareForReuse() {
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.redColor()
        selectedBackgroundView = backgroundView
    }
    
}
