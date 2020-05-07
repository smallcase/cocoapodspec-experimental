//
//  StocksCell.swift
//  WebViewTester
//
//  Created by Dip on 30/04/20.
//  Copyright © 2020 smallcase. All rights reserved.
//

import UIKit

class StocksCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var sharesLabel: UILabel!
    
    @IBOutlet weak var averagePriceLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
