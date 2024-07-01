//
//  NewsTableViewCell.swift
//  WebViewTester
//
//  Created by Shivani on 19/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {
    
    var newsItem: News? {
        didSet {
            guard let news = newsItem else {
                return
            }
            
            iconImageView.load(url: URL(string: news.imageUrl!)!)
            titleLabel.text = news.headline
        }
        
    }
    
    
    // MARK : - UI Component
    
    @IBOutlet weak var iconImageView: UIImageView! {
        didSet {
            iconImageView.layer.cornerRadius = 4
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
