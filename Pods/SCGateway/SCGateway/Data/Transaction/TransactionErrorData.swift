//
//  TransactionErrorData.swift
//  SCGateway
//
//  Created by Shivani on 18/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation

public struct TransactionErrorResponse: Codable {
    var value: Bool
    var message: String?
    var code: Int?
    
    enum CodingKeys: String, CodingKey {
        case value, message, code
    }
    
}
