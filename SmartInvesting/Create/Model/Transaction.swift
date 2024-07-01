//
//  Transaction.swift
//  WebViewTester
//
//  Created by Shivani on 16/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation


enum TransactionType: Int {
    case buy
    case sell
    case none
    
    var toString: String? {
        switch self {
        case .buy:
            return "BUY"
        case .sell:
            return "SELL"
        default:
            return nil
        }
    }
    
    
}
