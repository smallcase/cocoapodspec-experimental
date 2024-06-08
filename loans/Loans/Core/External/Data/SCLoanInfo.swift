//
//  LoanInfo.swift
//  Loans
//
//  Created by Ankit Deshmukh on 28/04/23.
//

import Foundation

@objc public class ScLoanInfo: NSObject {
    
    @objc let interactionToken: String
    
    @objc public init(interactionToken: String) {
        self.interactionToken = interactionToken
    }
    
    func toInternal(methodIntent: ScLoanIntent) -> ScLoanInfoInternal {
        return ScLoanInfoInternal(methodIntent: methodIntent, interactionToken: interactionToken)
    }
}

class ScLoanInfoInternal: ScLoanInfo {
    
    let methodIntent: ScLoanIntent
    
    init(methodIntent: ScLoanIntent, interactionToken: String) {
        self.methodIntent = methodIntent
        super.init(interactionToken: interactionToken)
    }
}
