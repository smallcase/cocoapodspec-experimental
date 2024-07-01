//
//  LASCoordinatorVMDelegate.swift
//  Loans
//
//  Created by Ankit Deshmukh on 06/05/23.
//

import Foundation

protocol LASCoordinatorVMDelegate {
    
    func concludeLOSJourney(_ result: ScLoanResult<ScLoanSuccess>)
}
