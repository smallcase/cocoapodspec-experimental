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

    public var errorMessage: String {
        switch  self {
        case .uninitialized:
            return "init_sdk"
            
        case .configNotSet:
            return "Gateway config is not set. Try calling setupConfig(_) method of SCGateway before intiailizing gateway"
 
        }
    }
    
    public var errorCode: Int {
        switch self {
            case .uninitialized:
                return 3004
            case .configNotSet:
                return 301
        }
    }
}


//MARK: Transactional Errors
public enum TransactionError: Error {
    
    case userMismatch
    case userMismatchWithData(data: Transaction.SuccessData?)
    case apiError
    case apiErrorWithData(data: Transaction.SuccessData?)
    case smtMarketClosed
    case smtMarketClosedWithData(data: Transaction.SuccessData?)
    case timedOutError
    
   // SDK initialised with invalid Gateway name
    case invalidGateway

    //JWT created with invalid secret or expired JWT
    case invalidJWT
    
    //Transaction expired while login or placing order on broker platform or user inactivity
    case transactionExpired
    case transactionExpiredWithData(data: Transaction.SuccessData?)
    
    // Internal SDK Errors
    case marketClosed
    case marketClosedWithData(data: Transaction.SuccessData?)
    
    case invalidUrl
    case invalidTransactionId
    case invalidResponse
    case custom(message: String)
    case dynamicError(msg: String, code: Int, data: Transaction.SuccessData?)
    
    case closedBrokerChooser
    case pressedTweet
    case noBrokerError
    case signupOtherBroker
    case transactionExpiredBefore
    
    case safariTabClosedInitialised
    case safariTabClosedInitialisedWithData(data: Transaction.SuccessData?)
    case safariTabClosedUsed
    case userLoggedInAndDropped(data: Transaction.SuccessData?)
    
    case alreadySubscribed
    case alreadySubscribedWithData(data: Transaction.SuccessData?)
    
    case intentNotEnabledForBroker
    case consentDenied
    case consentDeniedWithData(data: Transaction.SuccessData?)
    
    case orderPending(data: Transaction.SuccessData?)
    
    public var message: String {
        switch self {
            
            case .custom(let message):
                return message
            
            case .invalidGateway:
                return "invalid_gateway"
        
            case .invalidJWT:
                return "invalid_jwt"
        
            case .transactionExpiredWithData, .transactionExpired:
                return "transaction_expired"
            
            case .smtMarketClosed, .smtMarketClosedWithData, .marketClosed, .marketClosedWithData:
                return "market_closed"
        
            case .userMismatch, .userMismatchWithData:
                return "user_mismatch"
            
            case .timedOutError:
                return "timed_out"
        
            case .closedBrokerChooser:
                return "user_cancelled"
            
            case .pressedTweet:
                return "no_broker"
            
            case .noBrokerError:
                return "no_broker"
            
            case .signupOtherBroker:
                return "no_broker"

            case .transactionExpiredBefore:
                return "transaction_expired"
            
            case .safariTabClosedInitialised, .safariTabClosedInitialisedWithData:
                return "user_cancelled"
        
            case .safariTabClosedUsed, .userLoggedInAndDropped:
                return "user_cancelled"
        
            case .apiError, .apiErrorWithData:
                return "internal_error"
        
            case .dynamicError(let msg, _, _):
                return msg
        
            case .invalidTransactionId:
                return "invalid_transactionId"
            
            case .alreadySubscribed, .alreadySubscribedWithData:
                return "already_subscribed"
                
            case .intentNotEnabledForBroker:
                return "intent_not_enabled_for_broker"
                
            case .consentDenied, .consentDeniedWithData:
                return "consent_denied"
            
            case .orderPending:
                return "order_pending"
            
        default:
                return "internal_error"
        }
    }
    
    public var data: String? {
        
        var responseDict: [String: Any?] = [:]
        
        switch self {
                
            case .userLoggedInAndDropped(let transactionSuccessData),
                    .transactionExpiredWithData(let transactionSuccessData),
                    .safariTabClosedInitialisedWithData(let transactionSuccessData),
                    .apiErrorWithData(let transactionSuccessData),
                    .alreadySubscribedWithData(let transactionSuccessData),
                    .consentDeniedWithData(let transactionSuccessData),
                    .dynamicError(_, _, let transactionSuccessData),
                    .userMismatchWithData(let transactionSuccessData),
                    .smtMarketClosedWithData(let transactionSuccessData),
                    .marketClosedWithData(let transactionSuccessData),
                    .orderPending(let transactionSuccessData):
                
                guard let dataDict = transactionSuccessData.dictionary else {
                    return nil
                }
                
                responseDict["smallcaseAuthToken"] = dataDict["smallcaseAuthToken"]
                responseDict["broker"] = dataDict["broker"]
                
                if let signup = dataDict["signup"] {
                    responseDict["signup"] = signup
                }
                return responseDict.toJsonString
   
            default:
                
                guard let connectedAuthToken = SessionManager.sdkToken,
                      SessionManager.userStatus == .connected,
                      let currentBrokerName = SessionManager.userData?.broker?.name else {
                    return nil
                }
                
                responseDict["broker"] = currentBrokerName
                responseDict["smallcaseAuthToken"] = connectedAuthToken
                return responseDict.toJsonString
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
    
    // Value of error recieved from backend
    var errorValue: String? {
        
        switch self {
        case .invalidGateway:
            return "invalid gateway"
            
        case .invalidJWT:
            return "Invalid JWT"
            
            case .transactionExpiredWithData, .transactionExpired:
            return "TrxidExpired"
            
        default:
            return nil
            
        }
    }
    
    
    var markErrorStatus: String? {
        switch self {
            
        case .marketClosed, .marketClosedWithData:
            return "market_closed"
            
            case .apiError, .apiErrorWithData:
            return "internal_Error"
            
        case .timedOutError:
            return "timed_out"
            
        case .closedBrokerChooser:
            return "user_cancelled"
            
        case .pressedTweet:
            return "no_broker"
        
        case .noBrokerError:
            return "no_broker"
            
        case .signupOtherBroker:
            return "no_broker"
            
        case .transactionExpiredBefore:
            return "transaction_expired"
            
        case .safariTabClosedInitialised, .safariTabClosedInitialisedWithData:
            return "user_cancelled"
            
        case .safariTabClosedUsed, .userLoggedInAndDropped:
            return "user_cancelled"
            
        case .dynamicError:
            return message
            
        case .transactionExpiredWithData, .transactionExpired:
            return "transaction_expired"
            
        case .orderPending:
            return "order_pending"
            
        default:
            return nil
        }
    }
    
}


extension TransactionError: RawRepresentable {
    public var rawValue: Int {
        switch  self {
            case .userMismatch, .userMismatchWithData:
                return 1001
            
            case .apiError, .apiErrorWithData:
                return 2000
    
            case .smtMarketClosed, .smtMarketClosedWithData:
                return 4005
            
            case .marketClosed, .marketClosedWithData:
                return 4004
            
            case .timedOutError:
                return 4003
            
            case .invalidUrl:
                return 30

            case .invalidTransactionId:
                return 3002

            case .invalidResponse:
                return 60
            
            case .custom:
                return 1007

            case .invalidJWT:
                return 90
            
            case .invalidGateway:
                return 100
            
            case .transactionExpiredWithData, .transactionExpired:
                return 1005
            
            case .closedBrokerChooser:
                return 1010
            
            case .pressedTweet:
                return 1006
            
            case .noBrokerError:
                return 1008
            
            case .signupOtherBroker:
                return 1007
            
            case .transactionExpiredBefore:
                return 3001
            
            case .safariTabClosedInitialised, .safariTabClosedInitialisedWithData:
                return 1011
            
            case .safariTabClosedUsed, .userLoggedInAndDropped:
                return 1012
            
            case .alreadySubscribed, .alreadySubscribedWithData:
                return 4000
                
            case .intentNotEnabledForBroker:
                return 3000
                
            case .consentDenied, .consentDeniedWithData:
                return 1003
            
        case .orderPending:
            return 4006
            
            case .dynamicError(_, let code, _):
                return code
        }
    }
    
    public typealias RawValue = Int
    
    public init?(rawValue: RawValue) {
        switch rawValue {
        //Internal
        case 1001:  self =  .userMismatch
        case 2000:  self = .apiError
        case 4005: self = .smtMarketClosed
        case 4004: self = .marketClosed
        case 30: self = .invalidUrl
        case 3002: self = .invalidTransactionId
        case 60: self = .invalidResponse
//        case 80: self = .custom(message: "")
//        case 1007: self = .custom(message: "")
        case 90: self = .invalidJWT
        case 100: self = .invalidGateway
        case 1005: self = .transactionExpired
        case 4003: self = .timedOutError
        
        //new
        case 1010: self = .closedBrokerChooser
        case 1006: self = .pressedTweet
        case 1008: self = .noBrokerError
        case 1007: self = .signupOtherBroker
        case 3001: self = .transactionExpiredBefore
        case 1011: self = .safariTabClosedInitialised
        case 1012: self = .safariTabClosedUsed
        case 4000: self = .alreadySubscribed

        default:
            return nil
        }
    }
    
    public init?(rawValue:RawValue, message: String){
        self = .dynamicError(msg: message, code: rawValue, data: nil)
    }
    
    public init?(rawValue:RawValue, message: String, transactionSuccess: Transaction.SuccessData?){
        self = .dynamicError(msg: message, code: rawValue, data: transactionSuccess)
    }
    
    public init?(rawValue:RawValue, transactionData: Transaction.SuccessData?){
        
        switch rawValue {
            
            case 30: self = .invalidUrl
            case 60: self = .invalidResponse
            case 90: self = .invalidJWT
            case 100: self = .invalidGateway
            
            case 1001:  self = .userMismatchWithData(data: transactionData)
            case 1003: self = .consentDeniedWithData(data: transactionData)
            case 1005: self = .transactionExpiredWithData(data: transactionData)
            case 1006: self = .pressedTweet
            case 1007: self = .signupOtherBroker
            case 1008: self = .noBrokerError
            case 1010: self = .closedBrokerChooser
            case 1011: self = .safariTabClosedInitialisedWithData(data: transactionData)
            case 1012: self = .userLoggedInAndDropped(data: transactionData)
                
            case 2000:  self = .apiErrorWithData(data: transactionData)
            
            case 3001: self = .transactionExpiredBefore
            case 3002: self = .invalidTransactionId
            
            case 4000: self = .alreadySubscribedWithData(data: transactionData)
            case 4003: self = .timedOutError
            case 4004: self = .marketClosedWithData(data: transactionData)
            case 4005: self = .smtMarketClosedWithData(data: transactionData)
            case 4006: self = .orderPending(data: transactionData)
            
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
        super.init(domain: error.message, code: error.rawValue, userInfo: ["message": error.message, "data": error.data ?? ""])
    }
    
    init(error: SCGatewayError) {
        self.error = .apiError
        super.init(domain: error.errorMessage, code: TransactionError.apiError.rawValue, userInfo: ["message": error.errorMessage])
       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
