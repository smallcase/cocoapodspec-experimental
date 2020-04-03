//
//  UserData.swift
//  SCGateway
//
//  Created by Shivani on 06/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation

struct UserData: Codable {
    
    var broker: Broker?
    var investedSmallcases: [SmallcaseDetails]?
    var exitedSmallcases: [SmallcaseDetails]?
    
    //TODO:- Add actions
    
    private enum CodingKeys: String, CodingKey {
        case broker
        case investedSmallcases
        case exitedSmallcases
    }
    
}
