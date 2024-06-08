//
//  BrokerSelectViewModel+NativeLogin.swift
//  SCGateway
//
//  Created by Ankit Deshmukh on 30/08/22.
//  Copyright © 2022 smallcase. All rights reserved.
//

import Foundation

extension BrokerSelectViewModel {
    
    /// Check if native login is possible for a selected broker
    /// - Parameter forBroker: the broker requiring login
    /// - Returns: true/false based on the qualifiers for native login
    func isNativeLoginEnabled(_ forBroker: BrokerConfig?) -> Bool {
        
        ///First check if the selected broker is:
        /// 1) not nil
        /// 2) is allowed for native login (via initSession allowed brokers)
        /// 3) has a non-nil deeplink scheme
        /// 4) able to form a URL object from the deeplink scheme
        /// 5) broker native app installed in user's device
        /// Edge case:
        /// 6) can the user's device launch a "https" scheme URL
        
        if let selectedBroker = forBroker,
           let nativeLoginBrokers = SessionManager.allowedBrokers[AllowedBrokerType.NATIVE_IOS_LOGIN.rawValue], nativeLoginBrokers.contains(selectedBroker.broker),
           let brokerDeepLink = selectedBroker.deepLink,
           let brokerDeeplinkUrl = URL(string: brokerDeepLink),
           #available(iOS 13.0, *) {
            
            if UIApplication.shared.canOpenURL(brokerDeeplinkUrl) && UIApplication.shared.canOpenURL(URL(string: "https://www.google.com")!){
                SessionManager.nativeBrokerLoginEnabled = true
                return true
            }
        }
        
        SessionManager.nativeBrokerLoginEnabled = false
        return false
    }
    
    func processBPRedirectionFromHostApp(withRedirectUrl: URL) {
        print("Broker Platform callback URL from host app: \(String(describing: withRedirectUrl))")
        
        if SessionManager.currentIntentString == "CONNECT" || SessionManager.showOrders {
            delegate?.changeState(to: .preConnect(brokerConfig: userBrokerConfig!), completion: nil)
        } else {
            delegate?.changeState(to: .orderFlowWaiting, completion: nil)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            guard let redirectUrlQueryParam = withRedirectUrl.valueOfQueryParam("redirectUrl") else {
                self.coordinatorDelegate?.transactionErrored(error: .apiError, successData: nil)
                return
            }
            
            self.openGateway(url: URL(string: redirectUrlQueryParam))
        }
    }
    
    func launchNativeBrokerApp() {
        
        if let nativeLink = self.webAuthCompletionUrl?.valueOfQueryParam("nativeLink") {
            
            UIApplication.shared.open(URL(string: nativeLink)!, options: [:]) { success in
                
                SCGateway.shared.registerMixpanelEvent(
                    eventName: MixpanelConstants.EVENT_NATIVE_APP_LAUNCHED,
                    additionalProperties: [
                        "didLaunchSucceed": true,
                        "brokerDeepLink": nativeLink,
                        "transactionId": SessionManager.currentTransactionId ?? "NA",
                        "transactionStatus": SessionManager.currentTransactionIdStatus?.status ?? "NA",
                        "intent": SessionManager.currentIntentString ?? "NA",
                    ])
                
                self.delegate?.changeState(to: .nativeLoginFallback(brokerConfig: self.userBrokerConfig!), completion: { _ in
                    
                    if #available(iOS 13, *) {
                        if let gatewayAuthProvider = self.gatewayAuthProvider as? GatewayAuthenticationProvider {
                            gatewayAuthProvider.cancel()
                            self.gatewayAuthProvider = nil
                        }
                    } else {
                        self.webAuthProvider.cancel()
                    }
                    
                })
            }
        } else {
            self.webAuthCompletion(callbackURL: self.webAuthCompletionUrl, err: self.webAuthCompletionError)
        }
        
    }
    
    private func processIncompleteTransaction(_ incompleteTransactionURL: URL) {
        
        guard let components = NSURLComponents(url: incompleteTransactionURL, resolvingAgainstBaseURL: true),
              let _ = components.path,
              let redirectParams = components.queryItems
        else {
            print("Invalid URL or redirect path missing")
            return
        }
        
        if let transactionStatus = redirectParams.first(where: { $0.name == "status" })?.value {
            
            if transactionStatus == "INCOMPLETE" && SessionManager.currentIntentString != "CONNECT" {
                self.initiateTransactionWebView(transactionId: self.transactionId, isNativeLogin: nil)
            }
        } else {
            print("SDK Didn't receive any transactionStatus")
            return
        }
    }
    
}
