//
//  UserInfo.swift
//  SCGateway
//
//  Created by Ankit Deshmukh on 11/01/23.
//  Copyright © 2023 smallcase. All rights reserved.
//

import Foundation

@objcMembers public class UserInfo: NSObject {
    
    public var userId: String
    
    public var idType: String
    
    @objc public init(userId: String, idType: String) {
        self.userId = userId
        self.idType = idType
    }
}
