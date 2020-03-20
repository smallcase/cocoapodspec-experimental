//
//  Investment.swift
//  SCGateway
//
//  Created by Shivani on 18/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation



struct Investment: Codable {
    
    var date: String?
    var iscid: String?
    var name: String
    var recommendedAction: String?
    var scid: String?
    var shortDescription: String?
    var status: String
    var returns: InvestedReturns?
    var currentConfig: CurrentConfig
    
    
    struct CurrentConfig: Codable {
        var constituents: [Constituent]
        
        
        private enum CodingKeys: String, CodingKey {
            case constituents
        }
    }
    
    
    enum CodingKeys: String, CodingKey {
        case date, iscid, name, recommendedAction, scid, shortDescription, status, returns, currentConfig
    }
}


struct InvestmentData: Codable {
    
  //  var actions: InvestedActions?
    var investment: Investment
    
    enum CodingKeys: String, CodingKey {
        case  investment
    }
}
