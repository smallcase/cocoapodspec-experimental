//
//  SCGatewaySuccess.swift
//  Loans
//
//  Created by Ankit Deshmukh on 28/04/23.
//

import Foundation

public typealias ScLoanResult<T> = Result<T, ScLoanError>

@objcMembers public class ScLoanSuccess: NSObject {
    
    public let isSuccess: Bool = true
    public let data: String?
    internal var code: Int
    internal var message: String
    
    init(data: String? = nil, code: Int = 0, message: String = "success") {
        self.data = data
        self.code = code
        self.message = message
    }
    
    public var asDictionary: [String: Any?] {
           return [
               "isSuccess": isSuccess,
               "code": code,
               "message": message,
               "data": data
           ]
       }
       
    public func toJsonString() -> String? {
           guard let jsonData = try? JSONSerialization.data(withJSONObject: asDictionary, options: []),
                 let jsonString = String(data: jsonData, encoding: .utf8) else {
               return nil
           }
           return jsonString
       }
}

@objc public class ScLoanError: NSError {

    public let isSuccess: Bool = false
    
    @objc public let errorCode: Int
    @objc public let errorMessage: String
    @objc public let data: String?
    
    @objc override public var domain: String {
        return errorMessage
    }
    
    @objc public override var code: Int {
        return errorCode
    }
    
    internal init(errorCode: Int, errorMessage: String, data: String? = nil) {
        self.errorCode = errorCode
        self.errorMessage = errorMessage
        self.data = data
        super.init(domain: errorMessage, code: errorCode, userInfo: ["data": data ?? ""])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static internal let internalError = ScLoanError(errorCode: 2000, errorMessage: "internal_error")
    static internal let initSdkError = ScLoanError(errorCode: 3004, errorMessage: "init_sdk")
    static internal let userCancelledError = ScLoanError(errorCode: 1012, errorMessage: "user_cancelled")
    static internal let invalidInteractionIntent = ScLoanError(errorCode: 4004, errorMessage: "invalid_intent")
    
    public var asDictionary: [String: Any?] {
            return [
                "isSuccess": isSuccess,
                "code": errorCode,
                "message": errorMessage,
                "data": data
            ]
        }

       public func toJsonString() -> String? {
            guard let jsonData = try? JSONSerialization.data(withJSONObject: asDictionary, options: []),
                  let jsonString = String(data: jsonData, encoding: .utf8) else {
                return nil
            }
            return jsonString
        }
}
