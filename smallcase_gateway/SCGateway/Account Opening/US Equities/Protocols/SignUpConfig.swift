//
//  SignUpConfig.swift
//  SCGateway
//
//  Created by Ankit Deshmukh on 17/10/22.
//  Copyright © 2022 smallcase. All rights reserved.
//

import Foundation

@objcMembers public class SignUpConfig: NSObject {

    public var opaqueId: String
    public var userInfo: UserInfo
    
    public var utmParams: UtmParams? = nil
    public var retargeting: Bool? = nil
    
    /// Only for Objective-C
    @objc public init(opaqueId: String,
                      userInfo: UserInfo) {
        self.opaqueId = opaqueId
        self.userInfo = userInfo
    }
    
    /// Only for Objective-C
    @objc public init(opaqueId: String,
                      userInfo: UserInfo,
                      utmParams: UtmParams? = nil,
                      retargeting: AnyObject? = nil) {
        self.opaqueId = opaqueId
        self.userInfo = userInfo
        self.utmParams = utmParams
        if let retargetingArg = retargeting as? Bool {
            self.retargeting = retargetingArg
        } else {
            self.retargeting = nil
        }
    }
    
    public init(opaqueId: String,
                userInfo: UserInfo,
                utmParams: UtmParams? = nil,
                retargeting: Bool? = nil) {
        self.opaqueId = opaqueId
        self.userInfo = userInfo
        self.utmParams = utmParams
        self.retargeting = retargeting
    }
    
    /// Only for Objective-C
    @objc public init(opaqueId: String,
                      userInfo: UserInfo,
                      retargeting: AnyObject? = nil) {
        self.opaqueId = opaqueId
        self.userInfo = userInfo
        if let retargetingArg = retargeting as? Bool {
            self.retargeting = retargetingArg
        } else {
            self.retargeting = nil
        }
    }
    
    public init(opaqueId: String,
                userInfo: UserInfo,
                retargeting: Bool? = nil) {
        self.opaqueId = opaqueId
        self.userInfo = userInfo
        self.retargeting = retargeting
    }
    
    /// Only for Objective-C
    @objc public init(opaqueId: String,
                      userInfo: UserInfo,
                      utmParams: UtmParams? = nil) {
        self.opaqueId = opaqueId
        self.userInfo = userInfo
        self.utmParams = utmParams
    }
    
}
