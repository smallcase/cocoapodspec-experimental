//
//  Transactions.swift
//  SCGateway
//
//  Created by Shivani on 12/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation

public enum TransactionIntent {
    
    case connect(response: String)
    case onboarding(response: String)
    case subscription(_ response: String)
    case transaction(smallcaseAuthToken: String, transactionData: Transaction.SuccessData)
    case mfTransaction(data: String?)
    case holdingsImport(smallcaseAuthToken: String, broker: String, status: Bool,transactionId: String, signup: Bool?)
    case fetchFunds(smallcaseAuthToken:String, fund:Double, transactionId:String, signup: Bool?)
    case authoriseHoldings(smallcaseAuthToken:String, status:Bool,transactionId:String, signup: Bool?)
    case sipSetup(smallcaseAuthToken:String, sipAction:SipDetail, transactionId:String, signup: Bool?)
    case cancelAMO(_ transactionResponse: String)
    case mfHoldingsImport(data: String?)
}

public enum AllowedBrokerType : String{
    case SST = "sst"
    case SMT = "smt"
    case HOLDINGS_IMPORT = "holdingsImport"
    case CONNECT = "connect"
    case SIP_SETUP = "sipSetup"
    case FETCH_FUNDS = "fetchFunds"
    case AUTHORISE_HOLDINGS = "authoriseHoldings"
    case SHOW_ORDERS = "showOrders"
    case NATIVE_IOS_LOGIN = "nativeIOSLogin"
}

//MARK: Intent = CONNECT
@objc(ObjCTransactionIntentConnect)
final public class _ObjCTransactionIntentConnect: NSObject {
    
    @objc public let response: String

    init(_ response: String) {
        self.response = response
    }
}

//MARK: Intent = ONBOARDING
@objc(ObjCTransactionIntentOnboarding)
final public class _ObjCTransactionIntentOnboarding: NSObject {
    
    @objc public let response: String

    init(_ response: String) {
        self.response = response
    }
}

//MARK: Intent = MF_HOLDINGS_IMPORT
@objc(ObjCTransactionIntentMfHoldingsImport)
final public class _ObjCTransactionIntentMfHoldingsImport: NSObject {
    
    @objc public let data: String?

    init(_ data: String?) {
        self.data = data
    }
}

//MARK: Intent = SUBSCRIPTION
@objc(ObjCTransactionIntentSubscription)
final public class _ObjCTransactionIntentSubscription: NSObject {
    
    @objc public let response: String
    
    init(_ response: String) {
        self.response = response
    }
    
}

//MARK:  Intent = CANCEL_AMO
@objc(ObjCTransactionIntentCancelAmo)
final public class _ObjCTransactionIntentCancelAmo: NSObject {
    
    @objc public let response: String
    
    init(_ response: String) {
        self.response = response
    }
    
}

//MARK:  Intent = TRANSACTION
@objc(ObjcTransactionIntentTransaction)
final public class _ObjcTransactionIntentTransaction: NSObject {
    @objc public let authToken: String
    @objc public let transaction: String?
    
    let transactionData: Transaction.SuccessData
    
    init(_ authToken: String, _ transactionData: Transaction.SuccessData) {
        self.authToken = authToken
        self.transactionData = transactionData
        self.transaction = try? JSONEncoder().encode(transactionData).base64EncodedString()     }
    
}

//MARK:  Intent = MF-TRANSACTION
@objc(ObjcMfTransactionIntentTransaction)
final public class _ObjcMfTransactionIntentTransaction: NSObject {
    @objc public let data: String?
        
    init(_ data: String?) {
        self.data = data
    }
    
}

//MARK:  Intent = HOLDINGS_IMPORT
@objc(ObjcTransactionIntentHoldingsImport)
final public class _ObjcTransactionIntentHoldingsImport: NSObject {
    @objc public let authToken: String
    @objc public let broker: String
    @objc public let status: Bool
    @objc public let transactionId: String
    @objc public let signup: AnyObject?
    
    init(_ authToken: String, _ status: Bool, _ broker: String, _ transactionId: String, _ signup: Bool?) {
        self.authToken = authToken
        self.broker = broker
        self.status = status
        self.transactionId = transactionId
        self.signup = signup as AnyObject?

    }
}

//MARK:  Intent = FETCH_FUNDS
@objc(ObjcTransactionIntentFetchFunds)
final public class _ObjcTransactionIntentFetchFunds: NSObject {
    @objc public let authToken: String
    @objc public let fund: Double
    @objc public let transactionId: String
    @objc public let signup: AnyObject?
    
    init(_ authToken: String, _ fund: Double,_ transactionId: String, _ signup: Bool?) {
        self.authToken = authToken
        self.fund = fund
        self.transactionId = transactionId
        self.signup = signup as AnyObject?
    }
}

//MARK:  Intent = AUTHORISE_HOLDINGS
@objc(ObjcTransactionIntentAuthoriseHoldings)
final public class _ObjcTransactionIntentAuthoriseHoldings: NSObject {
    @objc public let authToken: String
    @objc public let status: Bool
    @objc public let transactionId: String
    @objc public let signup: AnyObject?
    
    init(_ authToken: String, _ status: Bool,_ transactionId: String, _ signup: Bool?) {
        self.authToken = authToken
        self.status = status
        self.transactionId = transactionId
        self.signup = signup as AnyObject?
    }
}

//MARK:  Intent = SIP_SETUP
@objc(ObjcTransactionIntentSipSetup)
final public class _ObjcTransactionIntentSipSetup: NSObject {
    @objc public let authToken: String
    @objc public let sipActive: Bool
    @objc public let sipAction: String
    @objc public let transactionId: String
    @objc public let sipAmount: Double
    @objc public let frequency: String
    @objc public let iscid: String
    @objc public let scheduledDate: String
    @objc public let scid: String
    @objc public let sipType: String
    @objc public let signup: AnyObject?
    let sipDetail: SipDetail
    
    init(_ authToken: String, _ sipAction: SipDetail,_ transactionId: String, _ signup: Bool?) {
        self.authToken = authToken
        self.sipDetail = sipAction
        self.sipActive = sipAction.sipActive ?? false
        self.sipAction = sipAction.sipAction ?? ""
        self.sipAmount = sipAction.amount ?? 0.0
        self.frequency = sipAction.frequency ?? ""
        self.iscid = sipAction.iscid ?? ""
        self.scheduledDate = sipAction.scheduledDate ?? ""
        self.scid = sipAction.scid ?? ""
        self.sipType = sipAction.sipType ?? ""
        self.transactionId = transactionId
        self.signup = signup as AnyObject?
    }
    
}



