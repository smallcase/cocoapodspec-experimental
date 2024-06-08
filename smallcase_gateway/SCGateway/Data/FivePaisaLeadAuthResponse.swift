//
//  FivePaisaLeadAuthResponse.swift
//  SCGateway
//
//  Created by Ankit Deshmukh on 18/01/21.
//  Copyright © 2021 smallcase. All rights reserved.
//

import Foundation

struct FivePaisaLeadAuthResponse : Codable {
    
    var success: Bool
    var errors: [String]?
    var data: FivePaisaLeadAuth?
    
    struct FivePaisaLeadAuth: Codable {
        var token: String
        
        private enum CodingKeys: String, CodingKey {
            case token
        }
    }
}
