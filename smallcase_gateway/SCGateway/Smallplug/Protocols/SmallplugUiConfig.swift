//
//  SmallplugUiConfig.swift
//  SCGateway
//
//  Created by Ankit Deshmukh on 03/06/22.
//  Copyright © 2022 smallcase. All rights reserved.
//

import Foundation

@objcMembers public class SmallplugUiConfig: NSObject {
    
    public var headerColor: String?
    public var backIconColor: String?
    
    public var opacity: CGFloat?
    public var backIconColorOpacity: CGFloat?
    
    @objc public init(
        smallplugHeaderColor: String?,
        headerColorOpacity: NSNumber?,
        backIconColor: String?,
        backIconColorOpacity: NSNumber?
    ) {
        self.headerColor = smallplugHeaderColor
        self.backIconColor = backIconColor
        self.opacity = headerColorOpacity as? CGFloat
        self.backIconColorOpacity = backIconColorOpacity as? CGFloat
    }

}
