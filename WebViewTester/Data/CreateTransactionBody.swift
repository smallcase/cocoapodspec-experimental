//
//  CreateTransactionBody.swift
//  WebViewTester
//
//  Created by Shivani on 15/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation


enum IntentType: String {
    case connect = "CONNECT"
    case transaction = "TRANSACTION"
    case holding = "HOLDINGS_IMPORT"
    case fetchFunds = "FETCH_FUNDS"
    case sipSetup = "SIP_SETUP"
    case authoriseHoldings = "AUTHORISE_HOLDINGS"
    case subscription = "SUBSCRIPTION"
}

enum OrderType: String {
    case buy = "BUY"
    case investMore = "INVESTMORE"
    case fix = "FIX"
    case manage = "MANAGE"
    case rebalance = "REBALANCE"
    case sip = "SIP"
    case exit = "EXIT"
    case securities = "SECURITIES"
    case repair = "REPAIR"
}
struct OrderConfig: Codable {
    var type: String?
    var scid: String?
    var iscid: String?
    var did: String?
    var orders: [Order]?
    
    private enum CodingKeys: String, CodingKey {
        case type, scid, iscid, did, orders = "securities"
    }
}

struct SubscriptionConfig: Codable {
    var scid: String?
    var iscid: String?
    
    private enum CodingKeys: String, CodingKey {
        case scid, iscid
    }
}

struct CreateTransactionBody: Codable {
    var id: String
    var intent: String
    var orderConfig: OrderConfig?
    
    enum CodingKeys: String, CodingKey {
        case id, intent, orderConfig
    }
    
}

struct CreateSubscriptionBody: Codable {
    var id: String
    var intent: String
    var config: SubscriptionConfig?
    
    enum CodingKeys: String, CodingKey {
        case id, intent, config
    }
}

struct Order: Codable {
    var ticker: String
    var type: String?
    var quantity: Int?
    
    private enum CodingKeys: String, CodingKey {
        case ticker , type, quantity
    }
}

