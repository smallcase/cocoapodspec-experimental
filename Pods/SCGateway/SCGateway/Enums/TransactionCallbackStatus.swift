//
//  TransactionCallbackStatus.swift
//  SCGateway
//
//  Created by Shivani on 11/03/20.
//  Copyright © 2020 smallcase. All rights reserved.
//

import Foundation

enum TransactionCallbackStatus: String {
    case completed = "COMPLETED"
    case errored = "ERRORED"
    case cancelled = "CANCELLED"
    case pending = "PENDING"
}


enum TransactionErrorReason: String {
    
    case transactionExpired = "TrxidExpired"
    case marketClosed = "MARKET_CLOSED"
    case userMismatch = "UserMismatch"
    case apiError = "APIError"
    case consentDenied = "CONSENT_DENIED"
    case insufficientHoldings = "INSUFFICIENT_HOLDINGS"
    case holdingmportError = "HoldingImportError"
}
