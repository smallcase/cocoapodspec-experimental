//
//  Broker.swift
//  SCGateway
//
//  Created by Shivani on 06/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation

struct Broker: Codable {
    var name: String?
    
    private enum CodingKeys:String, CodingKey {
        case name
    }
}
