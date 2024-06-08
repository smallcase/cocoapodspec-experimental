//
//  InitSessionResponse.swift
//  SCGateway
//
//  Created by Shivani on 06/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation

struct InitSessionResponse: Codable {
    var success: Bool
    var errors: [String]?
    var data: GatewayData?
    
    
    private enum CodingKeys: String, CodingKey {
        case success, errors, data
    }
    
}
