//
//  BrokerConfig.swift
//  SCGateway
//
//  Created by Shivani on 06/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation

struct BrokerConfig: Codable, Hashable {
    
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
    var popularity: Int
    var gatewayVisible: Bool
    var leprechaunURL: String?
    var gatewayLoginConsent:String?
    var nativeLoginEnabled: Bool?
    var packageName: String?
    var deeplinkScheme: String?
    var deepLink: String?
    
    private enum CodingKeys: String, CodingKey {
        
        case broker, brokerDisplayName, brokerShortName, platformURL, baseLoginURL, accountOpeningURL, isRedirectURL, trustedBroker, isIframePlatform, visible, topBroker, popularity, gatewayVisible, leprechaunURL,gatewayLoginConsent,nativeLoginEnabled,
             packageName,deeplinkScheme,deepLink
    }

}
