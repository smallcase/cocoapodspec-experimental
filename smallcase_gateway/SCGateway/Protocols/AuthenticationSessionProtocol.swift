//
//  AuthenticationSessionProtocol.swift
//  SCGateway
//
//  Created by Shivani on 07/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation
import AuthenticationServices
import SafariServices

protocol AuthenticationSessionProtocol {
    
    init(url URL: URL,
         callbackURLScheme: String?,
         completionHandler: @escaping (URL?, Error?) -> Void)
    func start() -> Bool
    func cancel()
}

extension SFAuthenticationSession: AuthenticationSessionProtocol {}

//@available(iOS 12.0, *)
//extension ASWebAuthenticationSession: AuthenticationSessionProtocol {}

class AuthenticationSession: AuthenticationSessionProtocol {
    
    private let innerAuthenticationSession: AuthenticationSessionProtocol
    
    required init(url URL: URL,
                  callbackURLScheme: String?,
                  completionHandler: @escaping (URL?, Error?) -> Void) {
        
//        if #available(iOS 12, *) {
//            innerAuthenticationSession = ASWebAuthenticationSession(url: URL, callbackURLScheme: callbackURLScheme, completionHandler: completionHandler)
//        } else {
//            innerAuthenticationSession = SFAuthenticationSession(url: URL, callbackURLScheme: callbackURLScheme, completionHandler: completionHandler)
//        }
        
        innerAuthenticationSession = SFAuthenticationSession(url: URL, callbackURLScheme: callbackURLScheme, completionHandler: completionHandler)
    }
    
    func start() -> Bool {
        return innerAuthenticationSession.start()
    }
    
    func cancel() {
        innerAuthenticationSession.cancel()
    }
}
