//
//  ExitedSmallcaseResponse.swift
//  WebViewTester
//
//  Created by Shivani on 18/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation

struct ExitedSmallcase: Codable {
    var iscid: String
    var name: String
    var date: String
    var dateSold: String
    var returns: InvestedReturns?
    
    enum Codingkeys: String, CodingKey {
        case iscid, name, date, dateSold, returns
    }
}


struct ExitedSmallcaseResponse: Codable {
    
    var success: Bool
    var errors: [String]?
    var data: [ExitedSmallcase]?
    
    enum CodingKeys: String, CodingKey {
        case success, errors, data
    }
}
