//
//  ScLoanIntent.swift
//  Loans
//
//  Created by Indrajit Roy on 06/10/23.
//

import Foundation

enum ScLoanIntent: String {
    case LOAN_APPLICATION = "LOAN_APPLICATION"
    case PAYMENT = "PAYMENT"
    case WITHDRAW = "WITHDRAW"
    case SERVICE = "SERVICE"
    
    var subIntents: [String] {
        switch self {
        case .LOAN_APPLICATION:
            return ["LOAN_APPLICATION:TOP_UP", "LOAN_APPLICATION:RENEWAL"]
        default:
            return []
        }
    }
}
