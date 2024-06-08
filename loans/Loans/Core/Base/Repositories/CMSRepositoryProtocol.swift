//
//  CMSRepositoryProtocol.swift
//  Loans
//
//  Created by Ankit Deshmukh on 22/06/23.
//

import Foundation

internal protocol CMSRepositoryProtocol {
    
    var lenderConfig: [LenderConfigs]? { get }
    
    func loadLenderConfig(completion: @escaping(ScLoanSuccess?, ScLoanError?) -> Void)
    func loadLenderConfig(completion: @escaping ((ScLoanResult<ScLoanSuccess>) -> Void))
}
