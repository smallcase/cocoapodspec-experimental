//
//  Constants.swift
//  SCGateway
//
//  Created by Ankit Deshmukh on 08/07/21.
//  Copyright © 2021 smallcase. All rights reserved.
//

import Foundation

internal enum Constants {
    static let clientDeviceType = "iOS"
    static let imageBaseUrl = "https://assets.smallcase.com/smallcase/assets/brokerLogo/small/"
    static let loaderImageGifName = "smallcase-loader"
    static let leprechaunActiveMessage = "Leprechaun mode on"
    static let leprechaunInactiveMessage = "Leprechaun mode off"
    static let leprechaunPostFix = "-leprechaun"
    static let callbackUrlScheme = "scgateway"
    
    //invalid URLs for SafariViewController
    static let invalidURLs = ["https://vars.hotjar.com","about:blank"]
    
    /// Max number of times the request has to be polled
    static let MAX_POLL_COUNT = 3
    static let MAX_POLL_ORDER_REQUEST = 15
    static let MAX_POLL_HOLDINGS = 15
    
    // number of seconds delay between every poll request
    static let POLL_DELAY_INTERVAL = 2.0
    
    static let errored = "ERRORED"
    
    static let INTENT_TRANSACTION = "TRANSACTION"
    static let INTENT_HOLDINGS_IMPORT = "HOLDINGS_IMPORT"
}

internal enum MixpanelConstants {
    
    static var MIXPANEL_PROJECT_KEY: String? {
        
        switch SessionManager.baseEnvironment {
                
            case .development:
                return "952676d310d87d9665e5d79f88cc8814"
                
            case .staging:
                return "a3af0b44f831787af872a7488ddff259"
                
            case .production:
                
                guard let mixpanelProjectKeyFromCopyConfig = SessionManager.copyConfig?.mixpanel?.projectKey else {
                    return nil
                }
                return mixpanelProjectKeyFromCopyConfig
                
            default:
                return nil
        }
    }
    
    static var vendorId: String? = nil
    
    static let EVENT_TRANSACTION_TRIGGERED = "SDK - Transaction triggered"
    static let EVENT_GATEWAY_CONNECT_VIEWED = "SDK - Gateway connect viewed"
    static let EVENT_BROKER_CHOOSER_VIEWED = "SDK - Broker-chooser viewed"
    static let EVENT_BROKER_SELECTED = "SDK - Broker selected"
    static let EVENT_BROKER_PLATFORM_OPENED = "SDK - Broker Platform Opened"
    static let EVENT_SDK_INTENT_RETURNED = "SDK - Intent Returned"
    static let EVENT_BP_RESPONSE_TO_PARTNER = "SDK - Response to partner"
    static let EVENT_LAUNCHED_LEAD_GEN_FROM_BROKER_CHOOSER = "SDK - Launched LeadGen from broker chooser"
    static let EVENT_USER_CLOSED = "SDK - User closed"
    static let EVENT_NATIVE_APP_LAUNCHED = "SDK - Native App Launched"
    static let EVENT_NATIVE_LOGIN_FALLBACK = "SDK - Triggered native login fallback"
}

internal enum NativeLoginConstants {
    static let FIRST_PARTY_UNIVERSAL_LINKS = ["www.smallcase.com","www.tickertape.in","gatewaydemo-dev.redirect.dev.smallcase.com"]
}

internal enum ScAssetUniverse: String {
    case MUTUAL_FUND = "MUTUAL_FUND"
}
