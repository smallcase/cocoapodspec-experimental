//
//  CreateTransactionResponse.swift
//  WebViewTester
//
//  Created by Shivani on 15/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation

struct CreateTransactionResponse: Codable {
    
    var err: String?
    var transactionId: String?
    
    enum CodingKeys: String, CodingKey {
        case err, transactionId
    }
}

