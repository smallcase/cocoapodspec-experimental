//
//  SmallcaseConstituentsTVCell.swift
//  WebViewTester
//
//  Created by Shivani on 15/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import UIKit

class SmallcaseConstituentsTVCell: UITableViewCell {
    
    var constiuents: Constituent? {
        didSet {
            sidLabel.text = constiuents?.ticker
            weightLabel.text = "\(constiuents?.weight ?? 0)"
            shareLabel.text = "\(constiuents?.shares ?? 0)"
        }
    }

    @IBOutlet weak var sidLabel: UILabel!
    
    @IBOutlet weak var weightLabel: UILabel!
    
    @IBOutlet weak var shareLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
