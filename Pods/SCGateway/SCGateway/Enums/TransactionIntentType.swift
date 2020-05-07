//
//  Transactions.swift
//  SCGateway
//
//  Created by Shivani on 12/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation

public enum TransactionIntent {
    
    case connect(smallcaseAuthToken: String, transactionData: Transaction)
    case transaction(smallcaseAuthToken: String, transactionData: OrderData)
    case holdingsImport(smallcaseAuthToken: String, status: Bool,transactionId: String)
}


@objc(ObjCTransactionIntentConnect)
final public class _ObjCTransactionIntentConnect: NSObject {
    @objc  public let authToken: String
    @objc public let transaction: String?
    
    let transactionData: Transaction
    
    
    init(_ authToken: String, _ transactionData: Transaction) {
        self.authToken = authToken
        self.transactionData = transactionData
        self.transaction = try? JSONEncoder().encode(transactionData).base64EncodedString()
    }
}

@objc(ObjcTransactionIntentTransaction)
final public class _ObjcTransactionIntentTransaction: NSObject {
    @objc public let authToken: String
    @objc public let transaction: String?
    
    let transactionData: OrderData
    
    init(_ authToken: String, _ transactionData: OrderData) {
        self.authToken = authToken
        self.transactionData = transactionData
        self.transaction = try? JSONEncoder().encode(transactionData).base64EncodedString()     }
    
}

@objc(ObjcTransactionIntentHoldingsImport)
final public class _ObjcTransactionIntentHoldingsImport: NSObject {
    @objc public let authToken: String
    @objc public let status: Bool
    @objc public let transactionId: String
    
    init(_ authToken: String, _ status: Bool,_ transactionId: String ) {
        self.authToken = authToken
        self.status = status
        self.transactionId = transactionId
    }
}
