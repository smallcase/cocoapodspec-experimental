//
//  PrivateSmallcaseCell.swift
//  WebViewTester
//
//  Created by Dip on 30/04/20.
//  Copyright © 2020 smallcase. All rights reserved.
//

import UIKit

class PrivateSmallcaseCell: UITableViewCell {

    @IBOutlet weak var currentValueLabel: UILabel!
    
    @IBOutlet weak var totalReturnsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
