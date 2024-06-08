//
//  SmallplugData.swift
//  SCGateway
//
//  Created by Ankit Deshmukh on 21/09/21.
//  Copyright © 2021 smallcase. All rights reserved.
//

import Foundation

@objcMembers public class SmallplugData: NSObject {
    
    public var targetEndpoint: String?
    public var params: String?
    
    @objc public init(_ targetEndpoint: String?, _ params: String?) {
        
        self.targetEndpoint = targetEndpoint
        self.params = params
        
    }
}
