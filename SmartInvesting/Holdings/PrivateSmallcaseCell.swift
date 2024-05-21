//
//  PrivateSmallcaseCell.swift
//  WebViewTester
//
//  Created by Dip on 30/04/20.
//  Copyright © 2020 smallcase. All rights reserved.
//

import UIKit

class PrivateSmallcaseCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var valueLabel: UILabel!
    
    @IBOutlet weak var privateScImage: UIImageView!
    
    @IBOutlet weak var totalReturns: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
