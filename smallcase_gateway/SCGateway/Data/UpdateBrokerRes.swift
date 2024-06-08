//
//  UpdateBrokerRes.swift
//  SCGateway
//
//  Created by Dip on 07/07/20.
//  Copyright © 2020 smallcase. All rights reserved.
//

import Foundation


struct UpdateDeviceResponse: Codable {
    var success: Bool
    
    
    private enum CodingKeys: String, CodingKey {
        case success
    }
    
}
