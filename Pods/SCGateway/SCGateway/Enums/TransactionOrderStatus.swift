//
//  TransactionOrderStatus.swift
//  SCGateway
//
//  Created by Shivani on 25/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation

public enum TransactionOrderStatus: String {
    
    case completed = "COMPLETED"        // switched by various services according to intent
    case initialized = "INITIALIZED"   // when started from be-be flow
    case used = "USED"                // when connect flow is validated, not valid for intent = CONNECT itself
    case processing = "PROCESSING"   // intent flow is in process, only valid for backgroud processes
    case errored = "ERRORED"        // client side error
    case cancelled = "CANCELLED"  // explicit user cancellation
    case expired = "EXPIRED"     // by EOD job

}

