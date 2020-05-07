//
//  Config.swift
//  SCGateway
//
//  Created by Shivani on 06/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation

internal enum Config {
    
    static var baseEnvironment: Environment = .production
    static var isLeprechaunActive: Bool = false
    static var brokerConfigType: BrokerConfigType?
    static var userStatus: UserStatus? = .guest
    static var gatewayName: String?
    static var gatewayToken: String?
    static var csrfToken: String?
    static var sdkToken: String?
    static var gateway: GatewayData?
    static var broker: Broker?
    static var brokerConfig: [BrokerConfig] = []
    static var copyConfig: GatewayCopyConfig?
    static var userBrokerConfig: BrokerConfig?
}

