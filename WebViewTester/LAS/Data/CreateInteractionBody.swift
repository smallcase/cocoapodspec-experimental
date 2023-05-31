//
//  CreateInteractionBody.swift
//  WebViewTester
//
//  Created by Ankit Deshmukh on 26/05/23.
//  Copyright © 2023 smallcase. All rights reserved.
//

import Foundation

struct CreateInteractionBody: Codable {
    var intent: String
    var config: CreateInteractionConfig
    
    struct CreateInteractionConfig: Codable {
        var amount: String?
        var type: String?
        var lender: String?
        var userId: String?
        var opaqueId: String?
  
//        enum CodingKeys: String, CodingKey {
//            case lender, userId, opaqueId
//        }
        
        enum CodingKeys: String, CodingKey {
            case amount, type, lender, userId, opaqueId
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case intent, config
    }
}
