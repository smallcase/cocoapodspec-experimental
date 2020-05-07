//
//  GatewayCopyConfigResponse.swift
//  SCGateway
//
//  Created by Shivani on 13/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation


struct CopyConfig: Codable {
    var title: String?
    var subTitle: String?
    var withError: String?
    var withoutError: String?
    var wrongUser: String?
    var defaultError: String?
    
    enum CodingKeys: String, CodingKey {
        case title, subTitle, withError, withoutError, wrongUser, defaultError
    }
}

struct GatewayCopyConfig: Codable {
    
    var connect: CopyConfig
    var postConnect: CopyConfig
    var loginFailed: CopyConfig
    var orderInQueue: CopyConfig
    var preConnect: CopyConfig
    var preBrokerChooser: CopyConfig?
    var orderFlowWaiting: CopyConfig
    var postHoldingsImport: CopyConfig?

   
    
    enum CodingKeys: String, CodingKey {
        case connect
        case postConnect = "post-connect"
        case loginFailed = "login-failed"
        case orderInQueue = "order-in-queue"
        case preBrokerChooser = "pre-broker-chooser"
        case preConnect = "pre-connect"
        case orderFlowWaiting = "orderflow-waiting"
        case postHoldingsImport = "post-holdings-import"
      
        
    }
    
}

