//
//  LASSessionManager.swift
//  WebViewTester
//
//  Created by Ankit Deshmukh on 29/05/23.
//  Copyright © 2023 smallcase. All rights reserved.
//

import Foundation
import Loans

enum LASSessionManager {
    
    static var envIndex: Int = 0 {
        didSet {
            switch self.envIndex {
            case 1:
                self.lasEnvironment = .development
                self.gatewayName = "gatewaydemo-dev"
                
            case 2:
                self.lasEnvironment = .staging
                self.gatewayName = "gatewaydemo-stag"
                
            default:
                self.lasEnvironment = .production
                self.gatewayName = "gatewaydemo"
            }
        }
    }
    
    static var lasEnvironment: SCLoanEnvironment!
    
    static var userId: String = ""
    static var pan: String = ""
    static var dob: String = ""
    static var lender: String = ""
    
    static var gatewayName: String = "gatewaydemo"
    
    static var lasUser: LASUser? = nil
    
    static var lasIntent: String = ""
    static var losAmount: String = ""
    static var losType: String = ""
}
