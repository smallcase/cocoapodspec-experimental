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
    case connected
    case loginFailed
    case loadHoldings
    case orderInQueue
    case orderFlowWaiting
    
    
    var copyConfig: CopyConfig? {
    switch self {
    case .connected:
        return Config.copyConfig?.postConnect
        
    case .loginFailed:
        return Config.copyConfig?.loginFailed
        
    case .loading:
        return Config.copyConfig?.preBrokerChooser
        
    case .brokerSelect:
        return Config.copyConfig?.connect
        
    case .orderInQueue:
        return Config.copyConfig?.orderInQueue
        
    case .orderFlowWaiting:
        return Config.copyConfig?.orderFlowWaiting
        
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
            let brokerStr =  Config.broker != nil ?  Config.copyConfig?.preConnect.title : Config.copyConfig?.preBrokerChooser?.title
            return brokerStr ?? "Connecting to broker gateway"
            
        case .loadHoldings:
            return Config.copyConfig?.postHoldingsImport?.title ?? "Fetching your holdings…"
            
        case .orderFlowWaiting:
            return copyConfig?.title
            
            
            
        default: return nil
        }
    }
    
    var loadingDescription: String? {
        switch self {
        case .loading:
            let descriptionString = Config.broker != nil ? Config.copyConfig?.preBrokerChooser?.subTitle : Config.copyConfig?.preConnect.subTitle
            return descriptionString ?? "Redirecting to the broker gateway. Do not press back, refresh or close the page."
        case .loadHoldings:
            return Config.copyConfig?.postHoldingsImport?.subTitle ?? "Please wait while we fetch holding details from your broker "
            
        case .orderFlowWaiting:
            return copyConfig?.subTitle
        default: return nil
        }
    }
    
    

    
}
