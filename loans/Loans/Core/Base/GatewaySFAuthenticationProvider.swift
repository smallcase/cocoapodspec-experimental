//
//  GatewaySFAuthenticationProvider.swift
//  Loans
//
//  Created by Ankit Deshmukh on 05/05/23.
//

import Foundation
import SafariServices
import AuthenticationServices

final class GatewaySFAuthenticationProvider {
    
    private let session: SFAuthenticationSession
    
    init(_ url: URL,_ callbackURLScheme: String?, completionHandler handler: @escaping (_ responseURL: URL?, _ error: Swift.Error?) -> ()) {
        
        print("launching url: \(url)")
        let completionHandler = { (url: URL?, error: Swift.Error?) in
            if #available(iOS 12.0, *), case ASWebAuthenticationSessionError.canceledLogin? = error {
                handler(url, GatewayLASJourneyError.cancelledLOSOrServicingFlow)
            } else if case SFAuthenticationError.canceledLogin? = error {
                handler(url, GatewayLASJourneyError.cancelledLOSOrServicingFlow)
            } else {
                handler(url, error)
            }
        }
        
        self.session = SFAuthenticationSession(url: url, callbackURLScheme: callbackURLScheme, completionHandler: completionHandler)
    }
    
    /**
     Starts the WebAuthenticationSession instance after it is instantiated.
     Start can only be called once for an WebAuthenticationSession instance. This also means calling start on a canceled session will fail.
     - Returns: Returns `true` if the session starts successfully.
     */
    @discardableResult func start() -> Bool {
        
        return session.start()
    }
    
    
    /**
     Cancel a WebAuthenticationSession. If the view controller is already presented to load the webpage for authentication, it will be dismissed. Calling cancel on an already canceled session will have no effect.
     */
    func cancel() {
        session.cancel()
    }
    
}
