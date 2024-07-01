//
//  SCGatewayLoanResult.swift
//  Loans
//
//  Created by Ankit Deshmukh on 28/04/23.
//

import Foundation

protocol SCGatewayLoanResultHandler {
    associatedtype ResponseDataType
    
    func onSuccess(_ response: ResponseDataType)
    func onFailure(_ error: Error)

}


public class SCGatewayLoanResult: SCGatewayLoanResultHandler {
    
    typealias ResponseDataType = ScLoanSuccess
    
    func onSuccess(_ response: ScLoanSuccess) {
        
    }
    
    func onFailure(_ error: Error) {
        
    }
    
}
