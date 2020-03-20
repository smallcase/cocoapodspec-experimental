//
//  AuthTokenResponse.swift
//  WebViewTester
//
//  Created by Shivani on 21/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation


struct GetAuthTokenResponse: Codable {
    var connected: Bool
    var smallcaseAuthToken: String?
    
    enum CodingKeys: String, CodingKey {
        case connected
        case smallcaseAuthToken
    }
}
