//
//  WebAuthentication.swift
//  SCGateway
//
//  Created by Shivani on 12/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation
import SafariServices
import AuthenticationServices

final class WebAuthenticationProvider {
    
    public enum Error: Swift.Error {
        case canceledLogin
    }
    
    private enum Session {
        
        @available(iOS 12.0, *)
        case asWebAuthenticationSession(ASWebAuthenticationSession)
    
        case sfAuthenticationSession(SFAuthenticationSession)
        
    }
    
    private let session: Session
    
    
    
    
    @available(iOS 13, *)
    init(url: URL, callbackURLScheme: String?, presentationContextProvider: ASWebAuthenticationPresentationContextProviding?,  completionHandler handler: @escaping (_ responseURL: URL?, _ error: Swift.Error?) -> ()) {
        print("url \(url)")
    let completionHandler = { (url: URL?, error: Swift.Error?) in
        
        if case ASWebAuthenticationSessionError.canceledLogin? = error {
            handler(url, Error.canceledLogin)
        } else if case SFAuthenticationError.canceledLogin? = error {
            handler(url, Error.canceledLogin)
        } else {
            handler(url, error)
        }
    }
    
 
        let webAuthSession = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackURLScheme, completionHandler: completionHandler)
            webAuthSession.presentationContextProvider = presentationContextProvider
        self.session = .asWebAuthenticationSession(webAuthSession)
        
}
    
    init(url: URL, callbackURLScheme: String?,  completionHandler handler: @escaping (_ responseURL: URL?, _ error: Swift.Error?) -> ()) {
        print("url \(url)")
        let completionHandler = { (url: URL?, error: Swift.Error?) in
            if #available(iOS 12.0, *), case ASWebAuthenticationSessionError.canceledLogin? = error {
                handler(url, Error.canceledLogin)
            } else if case SFAuthenticationError.canceledLogin? = error {
                handler(url, Error.canceledLogin)
            } else {
                handler(url, error)
            }
        }
        
        if #available(iOS 12.0, *) {
            let webAuthSession = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackURLScheme, completionHandler: completionHandler)
            self.session = .asWebAuthenticationSession(webAuthSession
            )
            
        } else {
            self.session = .sfAuthenticationSession(SFAuthenticationSession(url: url, callbackURLScheme: callbackURLScheme, completionHandler: completionHandler))
        }
    }

    
    
    /**
     Starts the WebAuthenticationSession instance after it is instantiated.
     
     Start can only be called once for an WebAuthenticationSession instance. This also means calling start on a canceled session will fail.
     
     - Returns: Returns `true` if the session starts successfully.
     */
    @discardableResult func start() -> Bool {

        switch session {
        case let .asWebAuthenticationSession(session):
            return session.start()
        case let .sfAuthenticationSession(session):
            return session.start()
        }
    }
    
    
    /**
     Cancel a WebAuthenticationSession. If the view controller is already presented to load the webpage for authentication, it will be dismissed. Calling cancel on an already canceled session will have no effect.
     */
    func cancel() {
        switch session {
        case let .asWebAuthenticationSession(session):
            session.cancel()
        case let .sfAuthenticationSession(session):
            session.cancel()
        }
    }
    
}

