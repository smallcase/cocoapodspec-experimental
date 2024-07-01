//
//  UtmParams.swift
//  SCGateway
//
//  Created by Ankit Deshmukh on 09/12/22.
//  Copyright © 2022 smallcase. All rights reserved.
//

import Foundation

@objcMembers final public class UtmParams: NSObject {
    
    public var utmSource: String? = nil
    public var utmMedium: String? = nil
    public var utmCampaign: String? = nil
    public var utmContent: String? = nil
    public var utmTerm: String? = nil
    
    @objc public init(utmSource: String? = nil, utmMedium: String? = nil, utmCampaign: String? = nil, utmContent: String? = nil, utmTerm: String? = nil) {
        self.utmSource = utmSource
        self.utmMedium = utmMedium
        self.utmCampaign = utmCampaign
        self.utmContent = utmContent
        self.utmTerm = utmTerm
    }
    
}
