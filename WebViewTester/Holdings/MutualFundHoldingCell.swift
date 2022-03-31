//
//  MutualFundHoldingCell.swift
//  WebViewTester
//
//  Created by Ankit Deshmukh on 28/03/22.
//  Copyright © 2022 smallcase. All rights reserved.
//

import UIKit

class MutualFundHoldingCell: UITableViewCell {

    @IBOutlet weak var mfFolio: UILabel!
    
    @IBOutlet weak var mfFund: UILabel!
    
    @IBOutlet weak var mfIsin: UILabel!
    
    @IBOutlet weak var mfPnl: UILabel!
    
    @IBOutlet weak var mfAvgPrice: UILabel!
    
    @IBOutlet weak var mfQuantity: UILabel!
    
    @IBOutlet weak var mfLastPrice: UILabel!
    
    @IBOutlet weak var mfLastPriceDate: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
