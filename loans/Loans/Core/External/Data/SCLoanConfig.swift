//
//  LASConfig.swift
//  Loans
//
//  Created by Ankit Deshmukh on 28/04/23.
//

import Foundation

@objc public class ScLoanConfig: NSObject {
    
    let gatewayName: String?
    let environment: SCLoanEnvironment?
    
    @objc public init(gatewayName: String) {
        self.gatewayName = gatewayName
        self.environment = .production
    }
    
    public init(gatewayName: String, environment: SCLoanEnvironment? = .production) {
        self.gatewayName = gatewayName
        self.environment = environment
    }
    
    @objc public init(gatewayName: String, environment: NSNumber? = 0) {
        self.gatewayName = gatewayName
        
        switch environment {
            case 1: self.environment = .development //1
            case 2: self.environment = .staging //2
            default: self.environment = .production //0
        }
    }
}
