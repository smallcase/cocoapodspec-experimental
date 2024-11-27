//
//  ScLoans+Mixpanel.swift
//  Loans
//
//  Created by Aaditya Singh on 07/02/24.
//

import Foundation
import Mixpanel
import UIKit

internal extension ScLoan {
    
    func setupMixpanel() {
        cmsAPI.getGatewayIosConfig { [weak self] result  in
            guard let self = self else { return }
            switch result {
            case .success:
                mixpanelSetup()
            case .failure:
                return
            }
        }
    }
    
    private func mixpanelSetup() {
        if let mixpanelKey = MixpanelConstants.MIXPANEL_PROJECT_KEY {
            guard let gatewayName = SessionManager.gatewayName else {return}
            let shouldUseMixpanel = SessionManager.gatewayIosConfig?.mixpanel?.gateways?.contains(gatewayName) ?? false
            if !shouldUseMixpanel {
                return
            }
            Mixpanel.initialize(token: mixpanelKey, trackAutomaticEvents: true)
        } else {
            self.mixpanelSetupInProgress = false
            self.mixpanelSetupComplete = false
            return
        }
        self.mixpanelSetupInProgress = true
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            MixpanelConstants.vendorId = uuid
        }
        self.registerMixpanelSuperProps([
            "device_id_sc": MixpanelConstants.vendorId
        ])
        self.mixpanelSetupInProgress = false
        self.mixpanelSetupComplete = true
    }
    
    /**
     * These properties are automatically included with all the tracked events
     * reference: https://developer.mixpanel.com/docs/swift#super-properties
     */
    /// - Parameter superProperties: the properties to persist for every mixpanel event
    
    func registerMixpanelSuperProps(_ superProperties: Properties?) {
        guard let superProps = superProperties else { return }
        Mixpanel.mainInstance().registerSuperProperties(superProps)
    }
    
    
    /// Register a mixpanel event with a given event name and properties
    /// - Parameters:
    ///   - eventName: The name of the event
    ///   - additionalProperties: properties in addition to the super properties added earlier
    
    func registerMixpanelEvent(eventName: String, additionalProperties: Properties) {
        var finalProps = additionalProperties
        finalProps["gatewayName"] = SessionManager.gatewayName ?? "unavailable"
        finalProps["SDK version"] = SessionManager.sdkVersion
        finalProps["SDK type"] = SessionManager.sdkType
        finalProps["SDK module"] = SessionManager.sdkModule
        finalProps["interactionToken"] = SessionManager.loanInfo?.interactionToken
        finalProps["lender"] = SessionManager.currentlenderInfo?.lenderName
        finalProps["productType"] = SessionManager.currentlenderInfo?.productType
        if self.mixpanelSetupComplete {
            Mixpanel.mainInstance().track(event: eventName, properties: finalProps)
        } else if self.mixpanelSetupInProgress {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                if self.mixpanelSetupComplete {
                    Mixpanel.mainInstance().track(event: eventName, properties: finalProps)
                }
            })
        } else {
            setupMixpanel()
        }
    }
    
}

