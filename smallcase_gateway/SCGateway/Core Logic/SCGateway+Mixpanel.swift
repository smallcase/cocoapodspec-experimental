//
//  SCGateway+Mixpanel.swift
//  SCGateway
//
//  Created by Ankit Deshmukh on 24/05/22.
//  Copyright © 2022 smallcase. All rights reserved.
//

import Foundation
import Mixpanel

internal extension SCGateway {
    
    func setupMixpanel() {
        
        if let mixpanelKey = MixpanelConstants.MIXPANEL_PROJECT_KEY {
            Mixpanel.initialize(token: mixpanelKey, trackAutomaticEvents: true)
        } else {
            self.mixpanelSetupInProgress = false
            self.mixpanelSetupComplete = false
            return
        }
        
        self.mixpanelSetupInProgress = true
        
        /**
         * Apple removed the truly unique identifier and instead introduced an identifier for each vendor: a UUID that's the same for all apps for a given developer for each user, but varies between developers and between devices.
         * [reference](https://www.hackingwithswift.com/example-code/system/how-to-identify-an-ios-device-uniquely-with-identifierforvendor):
         */
        
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            MixpanelConstants.vendorId = uuid
        }
        
        /// If the SDK has a smallcaseAuthId stored locally and host passes a GUEST user token, remove the smallcaseAuthId stored.
        if SessionManager.userStatus == .guest && (UserDefaults.standard.string(forKey: "smallcaseAuthId") != nil) {
            Mixpanel.mainInstance().reset()
            UserDefaults.standard.set("", forKey: "smallcaseAuthId")
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
        finalProps["SDK version"] = getSdkVersion()
        finalProps["SDK type"] = SessionManager.sdkType
        finalProps["SDK module"] = SessionManager.sdkModule
        
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
    
    /// Reset and setup mixpanel again if the SDK has a smallcaseAuthId already stored in UserDefaults and the SDK got initialised with a new smallcaseAuthId
    /// - Parameter newAuthId: the smallcaseAuthId of the new user
    func setupMixpanelForANewUser(_ newAuthId: String) {
        if self.mixpanelSetupComplete {
            Mixpanel.mainInstance().reset {
                
                self.identifyUser(newAuthId)
                
                self.registerMixpanelSuperProps([
                    "device_id_sc" : MixpanelConstants.vendorId
                ])
            }
        }
    }
    
    /// Identify this user for all the mixpanel events generated
    /// - Parameter authId: smallcaseAuthId of the user
    func identifyUser(_ authId: String) {
        if self.mixpanelSetupComplete {
            UserDefaults.standard.set(authId, forKey: "smallcaseAuthId")
            Mixpanel.mainInstance().identify(distinctId: authId)
        }
    }
    
}
