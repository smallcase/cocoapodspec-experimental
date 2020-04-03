//
//  GatewayConfig.swift
//  SCGateway
//
//  Created by Shivani on 21/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation

//@objc public protocol GatewayConfig {
//    var gatewayName: String { get set }
//    var brokerConfig: BrokerConfigType { get set }
//
//    //TODO:- Remove Later
//    var apiEnvironment: Environment { get set }
//    var isLeprechaunActive: Bool { get set}
//
//}
//

 @objcMembers public class GatewayConfig: NSObject {
    public var gatewayName: String!
    public var brokerConfig: BrokerConfigType!

    //TODO:- Remove Later
    public var apiEnvironment: Environment!
    public var isLeprechaunActive: Bool!
    
    //For Objective C compatibility, pass in broker config as empty or nil to use default config
    @objc public init(gatewayName: String, brokerConfig: [String]?, apiEnvironment: Environment, isLeprechaunActive: Bool) {
        
        if brokerConfig == nil || brokerConfig?.isEmpty ?? true {
            self.brokerConfig = .defaultConfig
        }
        else {
            self.brokerConfig = .custom(brokerConfig!)
        }
        self.gatewayName = gatewayName
        
        self.apiEnvironment = apiEnvironment
        self.isLeprechaunActive = isLeprechaunActive
    }
  

}
