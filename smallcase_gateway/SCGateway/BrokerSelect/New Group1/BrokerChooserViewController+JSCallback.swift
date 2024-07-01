//
//  BrokerChooserViewController+JSCallback.swift
//  SCGateway
//
//  Created by Ankit Deshmukh on 29/06/22.
//  Copyright © 2022 smallcase. All rights reserved.
//

import Foundation
import WebKit

extension BrokerChooserViewController: WKScriptMessageHandler {
    
    //MARK: Bridge Methods
    enum MessageHandlers {
        static let postToNativeSdk = "postToNativeSdk"
        static let toggleLeprechaunMode = "toggleLeprechaunMode"
        static let connectLoaded = "CONNECT_LOADED"
        static let showFrame = "SHOW_FRAME"
        static let loginButtonClicked = "LOGIN_BUTTON_CLICKED"
        static let userSignup = "USER_SIGNUP"
        static let userCancelled = "USER_CANCELLED"
    }
    
    //MARK: Javascript callbacks
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        guard let bodyString = message.body as? String, let bodyData = bodyString.data(using: .utf8) else {
            fatalError()
        }
        
        var type = ""
        var broker: String?
        
        var messageBody: [String: Any]
        
        do {
            messageBody = try JSONSerialization.jsonObject(with: bodyData, options: []) as! [String:Any]
            
            type = messageBody["type"] as! String
            
            broker = messageBody["broker"] as? String
            
        } catch {
            print(error)
        }
        
        if message.name == MessageHandlers.postToNativeSdk {
            
            switch type {
                case MessageHandlers.connectLoaded:
                    
                    webView.evaluateJavaScript(viewModel.getBrokerChooserJSCommand(), completionHandler: { _,_ in
                        SCGateway.shared.registerMixpanelEvent(
                            eventName: MixpanelConstants.EVENT_BROKER_CHOOSER_VIEWED,
                            additionalProperties: [
                                "intent": SessionManager.currentIntentString ?? "NA",
                                "ListOfBrokerPartnersShown": self.viewModel.getAvailableBrokers() ?? "NA",
                                "transactionId": SessionManager.currentTransactionId ?? "NA",
                                "transactionStatus": SessionManager.currentTransactionIdStatus?.status ?? "NA"
                            ])
                    })
                    
                case MessageHandlers.loginButtonClicked:
                    
                    if let brokerSelected = broker {
                        viewModel.launchBrokerPlatform(brokerName: brokerSelected.replacingOccurrences(of: Constants.leprechaunPostFix, with: ""))
                    }
                    
                case MessageHandlers.userSignup:
                    
                    viewModel.didTapSignup()
                    
                case MessageHandlers.userCancelled:
                    
                    viewModel.closeBrokerChooser()
                    
                case MessageHandlers.showFrame:
                    smallcaseLoaderImageView.isHidden = true
                    
                default:
                    return
            }
        }
        
        if message.name == MessageHandlers.toggleLeprechaunMode {
            
            print("Toggling leprechaun mode: \(!SessionManager.isLeprechaunActive)")
            
            if SessionManager.isLeprechaunActive {
                SessionManager.isLeprechaunActive = false
            } else {
                SessionManager.isLeprechaunActive = true
            }
            
        }
    }
}
