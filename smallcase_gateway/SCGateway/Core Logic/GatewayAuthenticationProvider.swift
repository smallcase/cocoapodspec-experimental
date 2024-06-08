//
//  GatewayAuthenticationProvider.swift
//  SCGateway
//
//  Created by Ankit Deshmukh on 07/07/22.
//  Copyright © 2022 smallcase. All rights reserved.
//

import Foundation
import AuthenticationServices
import SafariServices

@available(iOS 13.0, *)
final class GatewayAuthenticationProvider {
    
    private let session: ASWebAuthenticationSession
    
    init(
        url: URL,
        callbackURLScheme: String?,
        presentationContextProvider: ASWebAuthenticationPresentationContextProviding?,
        completionHandler handler: @escaping (_ responseURL: URL?, _ error: Swift.Error?) -> ()) {
            
            print("launching url: \(url)")
            
            let completionHandler = { (url: URL?, error: Swift.Error?) in
                if case ASWebAuthenticationSessionError.canceledLogin? = error {
                    handler(url, GatewayAuthenticationError.canceledLogin)
                } else if case SFAuthenticationError.canceledLogin? = error {
                    handler(url, GatewayAuthenticationError.canceledLogin)
                } else {
                    handler(url, error)
                }
            }
    
            let webAuthSession = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackURLScheme, completionHandler: completionHandler)
            webAuthSession.presentationContextProvider = presentationContextProvider
    
            self.session = webAuthSession
        }
    
    /**
     Starts the AsWebAuthenticationSession instance after it is instantiated.
     Start can only be called once for an WebAuthenticationSession instance. This also means calling start on a canceled session will fail.
     - Returns: Returns `true` if the session starts successfully.
     */
    @discardableResult func start() -> Bool {
        return session.start()
    }
    
    
    /**
     Cancel a WebAuthenticationSession. If the view controller is already presented to load the webpage for authentication, it will be dismissed.
     Calling cancel on an already canceled session will have no effect.
     */
    func cancel() {
        session.cancel()
    }
}
