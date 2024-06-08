//
//  RedirectURLParamsResponse.swift
//  SCGateway
//
//  Created by Shivani on 12/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation

struct RedirectURLParamsResponse: Codable {
    var success: Bool
    var data: ParamsData?
    var errors: [String]?
    var errorType: String?
    
    struct ParamsData: Codable {
        var redirectParams: String?
    }
    
    enum CodingKeys: String, CodingKey {
        case success, data, errors, errorType
    }
}
