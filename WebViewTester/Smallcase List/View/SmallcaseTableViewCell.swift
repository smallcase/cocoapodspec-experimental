//
//  SmallcaseTableViewCell.swift
//  WebViewTester
//
//  Created by Shivani on 15/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import UIKit

class SmallcaseTableViewCell: UITableViewCell {
    
    var smallcaseName: String? {
        get { return smallcaseLabel.text }
        set { smallcaseLabel.text = newValue }
    }
    
    

    @IBOutlet weak var smallcaseImageView: UIImageView! {
        didSet {
            smallcaseImageView.layer.cornerRadius = 24
        }
    }
    
    @IBOutlet weak var smallcaseLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
