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
            return "Fetching your holdings…"
        default: return nil
        }
    }
    
    var loadingDescription: String? {
        switch self {
        case .loading:
            let descriptionString = Config.broker != nil ? Config.copyConfig?.preBrokerChooser?.subTitle : Config.copyConfig?.preConnect.subTitle
            return descriptionString ?? "Redirecting to the broker gateway. Do not press back, refresh or close the page."
        case .loadHoldings:
            return "Please wait while we fetch holding details from your broker "
        default: return nil
        }
    }
    
    

    
}
