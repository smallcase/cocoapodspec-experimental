//
//  SmallplugViewController+WebView.swift
//  SCGateway
//
//  Created by Ankit Deshmukh on 03/06/22.
//  Copyright © 2022 smallcase. All rights reserved.
//

import Foundation
import WebKit

extension SmallPlugViewController: WKScriptMessageHandler{
    
    //MARK: JS Callbacks
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        switch message.name {
            case MessageHandlers.smallplugHandleIntent:
                
                if let messageBody = message.body as? String {
                    
                    let data = Data(messageBody.utf8)
                    
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            
                            if let transactionId = json["transactionId"] as? String, let intent = json["intent"] as? String {
                                triggerSmallPlugTransaction(transactionId, intent)
                            } else {
                                launchLeadGen()
                            }
                            
                        }
                    } catch let error as NSError {
                        print("Failed to convert message body to json: \(error.localizedDescription)")
                    }
                    
                }
                
                
            case MessageHandlers.getInitInfo:
                sendAuthDetailsToSmallplug()
                
            case MessageHandlers.closeSmallplug:
                didTapDismiss()
                
            default:
                print(message.name)
        }
        
        
    }
    
    //MARK: Gateway comms
    
    func sendAuthDetailsToSmallplug() {
        
        let initInfo = [
            "gatewayToken": SessionManager.gatewayToken,
            "gatewayName": SessionManager.gatewayName,
            "userStatus": SessionManager.userStatus == .guest ? "GUEST" : "CONNECTED",
            "sdkVersion": SCGateway.shared.getSdkVersion()
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: initInfo, options: [])
        
        let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
        
        let javascript = "window.getInitInfoResponse('\(jsonString)')"
        
        self.webView.evaluateJavaScript(javascript, completionHandler: nil)
        
        return
    }
    
    //MARK: Trigger smallplug transaction
    func triggerSmallPlugTransaction(_ txnId: String, _ intent: String) {
        
        var transactionResponse : [String: Any] = [:]
        
        do {
            try SCGateway.shared.triggerTransactionFlow(transactionId: txnId , presentingController: self) { [weak self]  result in
                switch result {
                    case .success(let response):
                        
                        transactionResponse["success"] = true
                        
                        print("Transaction: RESPONSE: \(response)")
                        
                        switch response {
                            case let .connect(connectResponse):
                                print(connectResponse)
                                
                                let data = Data(connectResponse.utf8)
                                
                                do {
                                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                        
                                        transactionResponse["response"] = json
                                        
                                        let jsonData = try! JSONSerialization.data(withJSONObject: transactionResponse, options: [])
                                        let jsonString = String(data: jsonData, encoding: .utf8)!
                                        
                                        let javascript = "window.handleIOSResponse('\(jsonString)')"
                                        
                                        self?.webView.evaluateJavaScript(javascript, completionHandler: nil)
                                        
                                    }
                                } catch let error as NSError {
                                    print("Failed to convert message body to json: \(error.localizedDescription)")
                                }
                                
                                
                            case let .transaction(authToken, transactionData):
                                print(authToken)
                                print(transactionData)
                                
                                transactionResponse["response"] = transactionData.dictionary
                                
                                SCGateway.shared.initializeGateway(sdkToken: authToken) { success, error in
                                    
                                    if !success {
                                        print(error ?? "")
                                        
                                        return
                                    }
                                    print("SDK initialised \(success)")
                                    
                                    let jsonData = try! JSONSerialization.data(withJSONObject: transactionResponse, options: [])
                                    let jsonString = String(data: jsonData, encoding: .utf8)!
                                    
                                    let javascript = "window.handleIOSResponse('\(jsonString)')"
                                    
                                    self?.webView.evaluateJavaScript(javascript, completionHandler: nil)
                                }
                                
                                
                            default:
                                return
                        }
                        
                        
                        
                    case .failure(let error):
                        
                        print("Smallplug Transaction ERROR :\(error)")
                        
                        var errorObject : [String: Any] = [
                            "errorCode" : error.rawValue
                        ]
                        
                        if error.rawValue == 1007 || error.rawValue == 1008 {
                            errorObject["error"] = "no_broker"
                        } else {
                            errorObject["error"] = error.message
                        }
                        
                        transactionResponse["success"] = false
                        transactionResponse["response"] = errorObject
                        
                        let jsonData = try! JSONSerialization.data(withJSONObject: transactionResponse, options: [])
                        let jsonString = String(data: jsonData, encoding: .utf8)!
                        
                        let javascript = "window.handleIOSResponse('\(jsonString)')"
                        
                        self?.webView.evaluateJavaScript(javascript, completionHandler: nil)
                        
                }
                
            }
        }
        catch SCGatewayError.uninitialized {
            print(SCGatewayError.uninitialized.errorMessage)
        }
        catch let err {
            print(err)
        }
        
    }
    
    //MARK: Launch Lead Gen
    
    func launchLeadGen() {
        let leadGenController = LeadGenController(params: nil, showLoader: true, leadGenUtmParams: nil, isRetargeting: nil)
        leadGenController.view.backgroundColor = UIColor.init(white: 0, alpha: 0.8)
        leadGenController.modalPresentationStyle = .overFullScreen
        
        self.present(leadGenController, animated: false, completion: nil)
    }
}
