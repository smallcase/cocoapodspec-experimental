//
//  MarkErroredResponse.swift
//  SCGateway
//
//  Created by Shivani on 18/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation

struct MarkErroredResponse : Codable {
    
    var success: Bool
    var errors: [String]?
    
    enum CodingKeys: String, CodingKey {
        case success, errors
    }
}
