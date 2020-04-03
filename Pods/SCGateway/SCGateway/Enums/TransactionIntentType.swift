//
//  Transactions.swift
//  SCGateway
//
//  Created by Shivani on 12/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation

public enum TransactionIntent {
    
    case connect(authToken: String, transactionData: Transaction)
    case transaction(authToken: String, transactionData: OrderData)
    case holdingsImport(authToken: String, status: String)
}


@objc(ObjCTransactionIntentConnect)
final public class _ObjCTransactionIntentConnect: NSObject {
    let authToken: String
    let transactionData: Transaction
    

    init(_ authToken: String, _ transactionData: Transaction) {
        self.authToken = authToken
        self.transactionData = transactionData
    }
}

@objc(ObjcTransactionIntentTransaction)
final public class _ObjcTransactionIntentTransaction: NSObject {
    let authToken: String
    let transactionData: OrderData
    
    init(_ authToken: String, _ transactionData: OrderData) {
        self.authToken = authToken
        self.transactionData = transactionData
    }
    
}

@objc(ObjcTransactionIntentHoldingsImport)
final public class _ObjcTransactionIntentHoldingsImport: NSObject {
    let authToken: String
    let status: String
    
    init(_ authToken: String, _ status: String) {
        self.authToken = authToken
        self.status = status
    }
}
