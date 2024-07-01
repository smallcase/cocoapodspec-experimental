//
//  MixpanelConstants.swift
//  Loans
//
//  Created by Aaditya Singh on 07/02/24.
//

import Foundation

internal class MixpanelConstants {
    private init() {}
    
    static var MIXPANEL_PROJECT_KEY: String? {
        return SessionManager.gatewayIosConfig?.mixpanel?.projectKey
    }
    
    static var vendorId: String? = nil
    
    static let EVENT_TRIGGERED_INTERACTION = "SDK - Triggered Interaction"
    static let EVENT_INTERACTION_INITIALISED = "SDK - Interaction Initialised"
    static let EVENT_UNITY_API_CALLED = "SDK - Unity API Called"
    static let EVENT_LOANS_PLATFORM_LAUNCHED = "SDK - Loans Platform Launched"
    static let EVENT_LOANS_PLATFORM_RESPONSE_RECEIVED = "SDK - Loans Platform Response Received"
    static let EVENT_RESPONSE_SENT_TO_PARTNER = "SDK - Response Sent To Partner"

}
