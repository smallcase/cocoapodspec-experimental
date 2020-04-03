//
//  GatewayData.swift
//  SCGateway
//
//  Created by Shivani on 06/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation


struct GatewayData: Codable {
    var csrf: String?
    var gatewayToken: String?
    var status: String?
    var userData: UserData?
    var displayName: String?
    var defaultSCName: String?
    var smallcaseAuthToken: String?
    
    
    private enum CodingKeys: String,CodingKey {
        case csrf, gatewayToken, status, userData, displayName, defaultSCName, smallcaseAuthToken
    }
    
}
