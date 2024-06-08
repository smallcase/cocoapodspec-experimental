//
//  SessionManager.swift
//  SCGateway
//
//  Created by Shivani on 06/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation

internal enum SessionManager {
    
    static var baseEnvironment: Environment = .production
    static var isLeprechaunActive: Bool = false
    static var brokerConfigType: BrokerConfigType?
    
    //Transaction
    static var currentTransactionId: String? = nil
    static var currentTransactionIdStatus: Transaction? = nil
    
    //User
    static var userStatus: UserStatus? = .guest
    static var userData: UserData? = nil
    static var smallcaseAuthId: String? = nil
    
    static var gatewayName: String?
    static var gatewayToken: String?
    static var csrfToken: String?
    static var sdkToken: String?
    
    static var gateway: GatewayData?
    
    static var broker: Broker?
    static var currentBroker: String?
    
    static var rawBrokerConfig: [BrokerConfig] = []
    static var brokerConfig: [BrokerConfig] = []
    static var copyConfig: GatewayCopyConfig?
    static var userBrokerConfig: BrokerConfig?
    static var tweetConfig: [UpcomingBroker] = []
    static var moreBrokers: [BrokerConfig] = []
    
    static var allowedBrokers: [String : [String]] = [:]
    static var allowedBrokersForIntent: [String]? = nil
    
    static var currentIntent:TransactionIntent? = nil
    static var currentIntentString: String? = nil
    
    static var type:String?
    static var isAmoEnabled:Bool = true
    static var currentlySelectedBroker:Broker?
    static var utmParams:Dictionary<String,String>? = nil
    
    static var currentSubscriptionConfig: SubscriptionConfig? = nil
    static var currentOrderConfig: OrderConfig? = nil
    static var currentOrderConfigMeta: MetaOrderConfig?
    
    static var allBrokers: [BrokerConfig] = []
    static var recentBrokers: [BrokerConfig] = []
    static var recentBrokerList: [String] = []
    
    static var leadGenUtmParams:Dictionary<String,String>? = nil
    static var isRetargeting: Bool? = false
    
    //smallplug vars
    static var smallplugTargetEndpoint: String? = nil
    static var smallplugUrlParams: String? = nil
    
    //Show orders
    static var showOrders: Bool = false
    
    //logs
    static var sdkType: String = "ios"
    static var sdkModule: String = "scgateway"
    static var hybridSDKVersion: String? = nil
    
    //native broker login
    static var nativeBrokerLoginEnabled: Bool = false
    
    //Mixpanel
    static var mixpanelSetupInProgress = false
    static var mixpanelSetupComplete = false
    static var vendorId: String? = nil
    
    static func shouldCheckMarketStatus() -> Bool {
        return !(SessionManager.currentOrderConfig?.type?.lowercased() == "rebalance" || SessionManager.currentOrderConfig?.type?.lowercased() == "dummy" || SessionManager.currentOrderConfig?.assetUniverse == ScAssetUniverse.MUTUAL_FUND.rawValue)
    }
    
    static var mobileConfig: [String: Any]? = nil
}

