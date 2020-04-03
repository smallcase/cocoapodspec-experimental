//
//  TransactionStatusResponse.swift
//  SCGateway
//
//  Created by Shivani on 13/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//


//todo:- map keys

struct TransactionStatusResponse: Codable {
    var success: Bool
    var errors: [String]?
    var data: TransactionData?
    
    struct TransactionData: Codable {
        var transaction: Transaction?
        
        private enum CodingKeys: String, CodingKey {
            case transaction
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case success, errors, data
    }
}
