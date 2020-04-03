//
//  BrokerConfig.swift
//  SCGateway
//
//  Created by Shivani on 06/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation

struct BrokerConfig: Codable {
    
    var broker: String
    var brokerDisplayName: String?
    var brokerShortName: String?
    var platformURL: String?
    var baseLoginURL: String
    var accountOpeningURL: String?
    var isRedirectURL: Bool
    var trustedBroker: Bool
    var isIframePlatform: Bool
    var visible: Bool
    var topBroker: Bool
    var gatewayVisible: Bool
    var leprechaunURL: String?
    
    
    
    private enum CodingKeys: String, CodingKey {
        
        case broker, brokerDisplayName, brokerShortName, platformURL, baseLoginURL, accountOpeningURL, isRedirectURL, trustedBroker, isIframePlatform, visible, topBroker, gatewayVisible, leprechaunURL
    }

}
