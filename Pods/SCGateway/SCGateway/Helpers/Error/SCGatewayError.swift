//
//  SCGatewayError.swift
//  SCGateway
//
//  Created by Shivani on 13/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation

public enum SCGatewayError: Int, Error {
    case uninitialized
    case configNotSet

    
    
    public var message: String {
        switch  self {
        case .uninitialized:
            return  "Gateway not initiailized. Try initializing gateway first"
            
        case .configNotSet:
            return "Gateway config is not set. Try calling setupConfig(_) method of SCGateway before intiailizing gateway"
 
        }
    }
}



public enum TransactionError: Error {
    
    case userMismatch
    case apiError
    case userCancelled
    case consentDenied
    case insufficientHoldings
    case userAbandoned
    case holdingsImportError
    case timedOutError
    case dismissBrokerChooserError
    
   // SDK initialised with invalid Gateway name
    case invalidGateway

    //JWT created with invalid secret or expired JWT
    case invalidJWT
    
    //Transaction expired while login or placing order on broker platform or user inactivity
    case transactionExpired
    
    // Internal SDK Errors
    case marketClosed
    case internalError
    case invalidUrl
    case invalidTransactionId
    case invalidResponse
    case custom(message: String)
    
    
    
    
    public var message: String {
        switch self {
            
        case .custom(let message):
            return message
            
        case .invalidGateway:
            return "invalid_gateway"
            
        case .invalidJWT:
            return "invalid_jwt"
            
        case .transactionExpired:
            return "transaction_expired"
            
        case .userAbandoned:
            return "order_in_queue"
            
        case .internalError:
            return "internal_error"
            
        case .userCancelled:
            return "user_cancelled"
        case .dismissBrokerChooserError:
            return "user_cancelled"
            
        case .userMismatch:
            return "user_mismatch"
            
        case .consentDenied:
            return "consent_denied"
            
        case.insufficientHoldings:
            return "insufficient_holdings"
            
        case .marketClosed:
            return "market_closed"
        case .timedOutError:
            return "timed_out"
        default:
            return "internal_error"
        }
    }
    
    
    public var debugMessage: String? {
        switch self {
        case .invalidGateway:
            return "SDK initialised with invalid Gateway name"
            
        case .invalidJWT:
            return "JWT created with invalid secret or expired JWT"
            
        default:
            return ""
        }
    }
    
    // VAlue of error recieved from backend
    var errorValue: String? {
        
        switch self {
        case .invalidGateway:
            return "invalid gateway"
            
        case .invalidJWT:
            return "Invalid JWT"
            
        case .transactionExpired:
            return "TrxidExpired"
            
        default:
            return nil
            
        }
    }
    
    
    var markErrorStatus: String?{
        switch self {
            
        case .marketClosed:
            return "MARKET_CLOSED_ERROR"
            
        case .apiError:
            return "API_ERROR"
            
        case .userCancelled:
            return "USER_CANCELLED"
        case .dismissBrokerChooserError:
            return "USER_CANCELLED"
            
        case .consentDenied:
            return "CONSENT_DENIED"
            
        case .insufficientHoldings:
            return "INSUFFICIENT_HOLDINGS"
            
        case .holdingsImportError:
            return "HOLDING_IMPORT_ERROR"
            
        case .timedOutError:
            return "TIMED_OUT"
            
        default:
            return nil
        }
    }
    
}


extension TransactionError: RawRepresentable {
    public var rawValue: Int {
        switch  self {
        case .userMismatch:
            return 1001
            
        case .apiError:
            return 2000
        case .holdingsImportError:
            return 2001
            
        case .userCancelled:
            return 1002
            
        case .dismissBrokerChooserError:
            return 1003
            
        case .consentDenied:
            return 1003
            
        case .insufficientHoldings:
            return 1004
            
        case .userAbandoned:
            return 1000
            
        case .marketClosed:
            return 4004
            
        case .timedOutError:
            return 4003
            
        case .internalError:
            return 20
            
        case .invalidUrl:
            return 30
            
        case .invalidTransactionId:
            return 40

        case .invalidResponse:
            return 60
            
        case .custom:
            return 80
            
        case .invalidJWT:
            return 90
            
        case .invalidGateway:
            return 100
            
        case .transactionExpired:
            return 110
            
            
        }
    }
    
    
    public typealias RawValue = Int
    public init?(rawValue: RawValue) {
        switch rawValue {
        //Internal
        case 1001:  self =  .userMismatch
        case 2000:  self = .apiError
        case 2001: self = .holdingsImportError
        case 1002: self = .userCancelled
        case 1003 : self = .consentDenied
        case 1004 : self = .insufficientHoldings
        case 1000: self = .userAbandoned
        case 4004: self = .marketClosed
        case 20: self = .internalError
        case 30: self = .invalidUrl
        case 40: self = .invalidTransactionId
        case 60: self = .invalidResponse
        case 80: self = .custom(message: "")
        case 90: self = .invalidJWT
        case 100: self = .invalidGateway
        case 110: self = .transactionExpired
        case 4003: self = .timedOutError
  

        default:
            return nil
        }
    }
}

@objc public class ObjcTransactionError: NSError {
    var error: TransactionError
    
     @objc override public var domain: String {
        return error.message
    }
    @objc public override var code: Int {
        return error.rawValue
    }
    
    init(error: TransactionError) {
         self.error = error
         super.init(domain: error.message, code: error.rawValue, userInfo: ["message": error.message])
       
    }
    
    init(error: SCGatewayError) {
        self.error = .internalError
        super.init(domain: error.message, code: TransactionError.internalError.rawValue, userInfo: ["message": error.message])
       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
