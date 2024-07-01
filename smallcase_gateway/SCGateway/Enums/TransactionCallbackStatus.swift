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
    case empty = ""
}


enum TransactionErrorReason: String {
    
    case transactionExpired = "transaction_expired"
    case marketClosed = "market_closed"
    case userMismatch = "user_mismatch"
    case apiError = "internal_error"
    case alreadySubscribed = "already_subscribed"
}
