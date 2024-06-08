//
//  MFTransactionStatusResponse.swift
//  SCGateway
//
//  Created by Indrajit Roy on 22/09/22.
//  Copyright © 2022 smallcase. All rights reserved.
//

import Foundation

struct MFTransactionStatusResponse: Codable {
    var success: Bool
    var errors: [String]?
    var data: MFTransactionData?
    var errorType: String?
    
    struct MFTransactionData: Codable {
        var transaction: MFTransaction?
        
        private enum CodingKeys: String, CodingKey {
            case transaction
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case success, errors, data , errorType
    }
}
