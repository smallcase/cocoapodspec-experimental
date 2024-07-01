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
    var subTitle2: SubTitle2?
    var withError: String?
    var withoutError: String?
    var wrongUser: String?
    var defaultError: String?
    var tweetMessage: String?
    var show:Bool?
    
    enum CodingKeys: String, CodingKey {
        case title, subTitle, subTitle2, withError, withoutError, wrongUser, defaultError, tweetMessage, show
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
    var clickToContinue: CopyConfig?
    var mixpanel: MixpanelConfig?
    
    struct MixpanelConfig: Codable {
        var projectKey: String?
        
        enum CodingKeys: String, CodingKey {
            case projectKey
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case connect
        case postConnect = "post-connect"
        case loginFailed = "login-failed"
        case orderInQueue = "order-in-queue"
        case preBrokerChooser = "pre-broker-chooser"
        case preConnect = "pre-connect"
        case orderFlowWaiting = "orderflow-waiting"
        case postHoldingsImport = "post-holdings-import"
        case clickToContinue = "click-to-continue"
        case mixpanel = "mixpanel"
    }
    
}

struct SubTitle2: Codable {
    var transaction: String?
    var fetchFunds: String?
    var holdingsImport: String?
    var defaultCase: String?
    
    enum CodingKeys: String, CodingKey {
        case transaction = "TRANSACTION"
        case fetchFunds = "FETCH_FUNDS"
        case holdingsImport = "HOLDINGS_IMPORT"
        case defaultCase = "default"
    }
    
}

