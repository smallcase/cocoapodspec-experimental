//
//  LASUser.swift
//  WebViewTester
//
//  Created by Ankit Deshmukh on 30/05/23.
//  Copyright © 2023 smallcase. All rights reserved.
//

import Foundation

struct LASUser {
    var lasUserId: String
    var opaqueId: String
    
    enum CodingKeys: String, CodingKey {
        case lasUserId, opaqueId
    }
}
