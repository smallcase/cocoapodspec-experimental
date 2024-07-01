//
//  AllInvestmentsResponse.swift
//  WebViewTester
//
//  Created by Shivani on 18/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation


struct AllInvestmentsResponse: Codable {
    var success: Bool
    var errors: [String]?
    var data: [InvestmentData]?
    
    
    enum CodingKeys: String, CodingKey {
        case success, errors, data
    }
}
