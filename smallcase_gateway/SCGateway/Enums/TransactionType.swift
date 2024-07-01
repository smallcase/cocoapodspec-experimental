//
//  Transactions.swift
//  SCGateway
//
//  Created by Shivani on 12/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation

public enum TransactionIntentType {
    
    case connect(authToken: String, status: String, transactionData: Transaction)
    case transaction(status: String, transactionData: Transaction)
    case holdingsImport(status: String)
}
