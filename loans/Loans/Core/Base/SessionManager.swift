//
//  SessionManager.swift
//  Loans
//
//  Created by Ankit Deshmukh on 04/05/23.
//

import Foundation

internal enum SessionManager {
    //MARK: Environment
    static var baseEnvironment: SCLoanEnvironment = .production
    
    //MARK: SDK specifics
    static var sdkType: String = "iOS"
    static var hybridSdkVersion: String? = nil
    static let sdkModule = "loans"
    static var sdkVersion: String {
        let version = Bundle.init(for: ScLoan.self).infoDictionary!["CFBundleShortVersionString"] ?? "0.0.1"
        return String(describing: version)
    }
    
    static var sdkVersionCode: String {
        let version = Bundle.init(for: ScLoan.self).infoDictionary!["CFBundleVersion"] ?? "0"
        return String(describing: version)
    }
    
    //MARK: Host constants
    static var gatewayName: String? = nil
    
    //MARK: UIConfig
    static var lenderConfig: [LenderConfigs]? = nil
    
    //MARK: Loan Specific
    static var loanInfo: ScLoanInfoInternal? = nil
    
    static var gatewayIosConfig: GatewayIosConfig? = nil
}
