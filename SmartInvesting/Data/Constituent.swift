//
//  Constituent.swift
//  WebViewTester
//
//  Created by Shivani on 18/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation

struct Constituent: Codable {
    var shares: Double?
    var stockName: String
    var ticker: String
    var weight: Double?
    var returns: Double?
    var averagePrice: Double?
    
    enum CodingKeys: String, CodingKey {
        case shares, stockName, ticker, weight, returns, averagePrice
    }
}
