//
//  ViewState.swift
//  SCGateway
//
//  Created by Shivani on 21/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation

enum ViewState {
    
    case loading(showBrokerLoading: Bool)
    case brokerSelect
    case preConnect(brokerConfig:BrokerConfig)
    case connected
    case loginFailed
    case loadHoldings
    case orderInQueue
    case orderFlowWaiting
    case connectedConsent(brokerConfig:BrokerConfig)
    case nativeLoginFallback(brokerConfig:BrokerConfig)
    
    var copyConfig: CopyConfig? {
    switch self {
    case .connected:
        return SessionManager.copyConfig?.postConnect
        
    case .loginFailed:
        return SessionManager.copyConfig?.loginFailed
        
    case .loading:
        return SessionManager.copyConfig?.preBrokerChooser
        
    case .brokerSelect:
        return SessionManager.copyConfig?.connect
        
    case .orderInQueue:
        return SessionManager.copyConfig?.orderInQueue
        
    case .orderFlowWaiting:
        return SessionManager.copyConfig?.orderFlowWaiting
        
    case .preConnect:
        return SessionManager.copyConfig?.preConnect
            
    default:
        return nil
        
    }
    
}
    
    var iconImage: UIImage? {
        switch self {
        case .connected:
            return images[ImageConstants.successIcon]!
            
        case .loginFailed:
            return images[ImageConstants.errorIcon]!
        
        case .orderInQueue:
            return images[ImageConstants.orderInQueue]!
            
        default:
            return nil
        }
    }
    
    var loadingText: String? {
        switch self {
        case .loading:
            let brokerStr =  SessionManager.broker != nil ?  SessionManager.copyConfig?.preConnect.title : SessionManager.copyConfig?.preBrokerChooser?.title
            return brokerStr ?? "Connecting to broker gateway"
            
        case .loadHoldings:
            return SessionManager.copyConfig?.postHoldingsImport?.title ?? "Fetching your holdings…"
            
        case .orderFlowWaiting:
            return copyConfig?.title
            
        case .preConnect:
            return copyConfig?.title
            
        default: return nil
        }
    }
    
    var loadingDescription: String? {
        switch self {
        case .loading:
//            let descriptionString = Config.broker != nil ? Config.copyConfig?.preBrokerChooser?.subTitle : Config.copyConfig?.preConnect.subTitle
            let descriptionString = SessionManager.broker != nil ?  SessionManager.copyConfig?.preConnect.subTitle : SessionManager.copyConfig?.preBrokerChooser?.subTitle
            return descriptionString ?? "Redirecting to the broker gateway. Do not press back, refresh or close the page."
        case .loadHoldings:
            return SessionManager.copyConfig?.postHoldingsImport?.subTitle ?? "Please wait while we fetch holding details from your broker "
            
        case .orderFlowWaiting:
            return copyConfig?.subTitle
            
        case .preConnect:
            return copyConfig?.subTitle
            
        default: return nil
        }
    }
    
}
