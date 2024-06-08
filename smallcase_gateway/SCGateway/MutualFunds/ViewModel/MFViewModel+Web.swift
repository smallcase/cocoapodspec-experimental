//
//  MFViewModel+Web.swift
//  SCGateway
//
//  Created by Indrajit Roy on 21/09/22.
//  Copyright © 2022 smallcase. All rights reserved.
//

import Foundation

protocol DispatchMessageI {
    func process(webViewTransactor: WebViewTransactor?)
}

class DispatchMessage: DispatchMessageI {
    func process(webViewTransactor: WebViewTransactor?) { }
    
    internal static func fromRaw(message: String) -> DispatchMessageI? {
        
        let data = Data(message.utf8)
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                
                let action = json["action"]
                if(action as? String == "SEND_TXN_STATUS") {
                    if let payload = json["payload"] as? [String:Any], let payloadJson = payload.toJsonString {
                        return TxnStatusMessage.fromRaw(payload: payloadJson)
                    }
                }
            }
        } catch let error as NSError {
            print("Failed to convert message body to json: \(error.localizedDescription)")
        }
        return nil
    }
}

class TxnStatusMessage : DispatchMessageI {
    
    var status: String
    var errorCode: Int?
    var error: String?
    
    init(status: String, errorCode: Int?, error: String?) {
        self.status = status
        self.errorCode = errorCode
        self.error = error
    }
    
    static func fromRaw(payload: String) -> TxnStatusMessage? {
        let data = Data(payload.utf8)
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                return TxnStatusMessage(status: json["status"] as! String, errorCode: json["code"] as? Int, error: json["error"] as? String)
            }
        } catch let error as NSError {
            print("Failed to convert message body to json: \(error.localizedDescription)")
        }
        return nil
    }
    
    func process(webViewTransactor: WebViewTransactor?) {
        var webException: WebException? = nil
        if (self.errorCode != nil && self.error != nil) {
            webException = WebException(status: self.status, code: self.errorCode ?? 0, error:  self.error ?? "")
        }
        webViewTransactor?.setTransactionStatus(webException: webException)
    }
}



