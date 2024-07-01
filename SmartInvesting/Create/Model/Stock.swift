//
//  Stock.swift
//  WebViewTester
//
//  Created by Shivani on 12/06/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation

struct Stock: Codable {
    
    var sid: String?
    var name: String?
    var ticker: String?

    
    
    enum CodingKeys: String, CodingKey {
        case sid, name, ticker
    }

    
}
