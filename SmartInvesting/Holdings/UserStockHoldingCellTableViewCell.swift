//
//  UserStockHoldingCellTableViewCell.swift
//  WebViewTester
//
//  Created by Ankit Deshmukh on 24/03/22.
//  Copyright © 2022 smallcase. All rights reserved.
//

import UIKit

class UserStockHoldingCellTableViewCell: UITableViewCell {

    @IBOutlet weak var userStockName: UILabel!
    
    @IBOutlet weak var userStockISIN: UILabel!
    
    @IBOutlet weak var userStockTransactableQty: UILabel!
    
    @IBOutlet weak var userStockSmallcaseQty: UILabel!
    
    @IBOutlet weak var userStockNseTicker: UILabel!
    
    @IBOutlet weak var nsePositionsShares: UILabel!
    
    @IBOutlet weak var nsePositionsAvgPrice: UILabel!
    
    @IBOutlet weak var bseTicker: UILabel!
    
    @IBOutlet weak var bsePositionsShares: UILabel!
    
    @IBOutlet weak var bsePositionsAvgPrice: UILabel!
    
    @IBOutlet weak var holdingsShares: UILabel!
    
    @IBOutlet weak var holdingsAvgPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
