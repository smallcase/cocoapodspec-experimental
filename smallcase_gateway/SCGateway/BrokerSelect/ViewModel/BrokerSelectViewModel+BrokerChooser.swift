//
//  BrokerSelectViewModel+BrokerChooser.swift
//  SCGateway
//
//  Created by Ankit Deshmukh on 07/06/22.
//  Copyright © 2022 smallcase. All rights reserved.
//

import Foundation


extension BrokerSelectViewModel {
    
    
    /// Fetch the URL for launching broker chooser based on the SDK environment
    /// - Returns: The URLRequest to be loaded inside the broker chooser webView
    func getWebBrokerChooserUrl() -> URLRequest {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        
        switch SessionManager.baseEnvironment {
            case .development:
                urlComponents.host = "connect-dev.smallca.se"
            case .staging:
                urlComponents.host = "connect-dev.smallca.se"
            default:
                urlComponents.host = "connect.smallca.se"
        }
        
        let queryItems = [
            URLQueryItem(name: "deviceType", value: "ios"),
            URLQueryItem(name: "gateway", value: SessionManager.gatewayName!)
        ]
        
        urlComponents.queryItems = queryItems
        
        return URLRequest(url: urlComponents.url!)
    }
    
    func launchBrokerPlatform(brokerName: String) {
        
        if let selectedBroker = SessionManager.allBrokers.first(where: { $0.broker == brokerName}) {
            
            SCGateway.shared.registerMixpanelEvent(
                eventName: MixpanelConstants.EVENT_BROKER_SELECTED,
                additionalProperties: [
                    "transactionId": SessionManager.currentTransactionId ?? "NA",
                    "transactionStatus": SessionManager.currentTransactionIdStatus?.status ?? "NA",
                    "intent": SessionManager.currentIntentString ?? "NA",
                    "ListOfBrokerPartnersShown": getAvailableBrokers() ?? "NA",
                    "BrokerNameSelected": selectedBroker.broker,
                    "isAppInstalled": isNativeLoginEnabled(selectedBroker)
                ])
            
            saveRecentlySelectedBroker(brokerName: selectedBroker.broker)
            
            self.userBrokerConfig = selectedBroker
        } else {return}
        
    }
    
    func saveRecentlySelectedBroker(brokerName: String) {
        
        var recentBrokersList: [String] = []
        
        if let recentBrokerArray = UserDefaults.standard.object(forKey: "recent_brokers_list") {
            recentBrokersList = recentBrokerArray as! [String]
        }
        
        if(!recentBrokersList.contains(where: { $0 == brokerName})) {
            recentBrokersList.append(brokerName)
        } else if (!recentBrokersList.isEmpty) {
            recentBrokersList.removeAll(where: {$0 == brokerName})
            recentBrokersList.append(brokerName)
        }
        
        SessionManager.recentBrokerList = recentBrokersList
        
        UserDefaults.standard.set(recentBrokersList, forKey: "recent_brokers_list")
        
    }
    
    func closeBrokerChooser() {
        
        if SessionManager.showOrders {
            SessionManager.showOrders = false
            self.coordinatorDelegate?.nonTransactionalIntentCompleted(success: true, error: nil)
        } else {
            
            SCGateway.shared.registerMixpanelEvent(
                eventName: MixpanelConstants.EVENT_USER_CLOSED,
                additionalProperties: [
                    "intent": SessionManager.currentIntentString ?? "NA",
                    "transactionId": SessionManager.currentTransactionId ?? "NA",
                    "transactionStatus": SessionManager.currentTransactionIdStatus?.status ?? "NA"
                ])
            
            SCGateway.shared.registerMixpanelEvent(
                eventName: MixpanelConstants.EVENT_BP_RESPONSE_TO_PARTNER,
                additionalProperties: [
                    "transactionId": SessionManager.currentTransactionId ?? "NA",
                    "transactionStatus": SessionManager.currentTransactionIdStatus?.status ?? "NA",
                    "intent": SessionManager.currentIntentString ?? "NA",
                    "error_code": TransactionError.closedBrokerChooser.rawValue,
                    "error_message": TransactionError.closedBrokerChooser.message
                ])
            
            markTransactionErrored(.closedBrokerChooser)
            self.coordinatorDelegate?.transactionErrored(error: .closedBrokerChooser, successData: nil)
            
        }
    }
    
    func getBrokerChooserJSCommand() -> String {
        
        let testDict: [String: Any] = [
            "type": "MANAGE_WINDOW",
            "argument": [
                "secondaryStatus":getBrokerChooserSecondaryStatus(),
                "intent": SessionManager.currentIntentString?.uppercased() ?? "",
                "intentData" : getIntentData(),
                "recentBrokers": getRecentlySelectedBrokers(),
                "isReturningUser": getRecentlySelectedBrokers().isEmpty ? false : true
            ]
        ]
        
        let jsonData = (try? JSONSerialization.data(withJSONObject: testDict, options: []))!
        
        let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
        
        let javascript = "window.postToConnect('\(jsonString)')"
        
        print(javascript)
        
        return javascript
    }
    
    private func getRecentlySelectedBrokers() -> [String] {
        
        var recentBrokersList: [String] = []
        
        if let recentBrokerArray = UserDefaults.standard.object(forKey: "recent_brokers_list") {
            recentBrokersList = recentBrokerArray as! [String]
            recentBrokersList = recentBrokersList.reversed()
        }
        
        return recentBrokersList
    }
    
    private func getBrokerChooserSecondaryStatus() -> String {
        
        var secondaryStatus = "connect?action=gatewayLogin"
        
        if let brokersForIntent = SessionManager.allowedBrokersForIntent {
            for broker in brokersForIntent {
                secondaryStatus.append("&b[]=\(broker)")
            }
        }
        
        secondaryStatus.append("&distributor=\(SessionManager.gateway!.displayName!)&gateway=\(SessionManager.gatewayName!)&leprechaun=\(SessionManager.isLeprechaunActive)&deviceType=ios")
        
        return secondaryStatus
    }
    
    private func getIntentData() -> [String : Any] {
        
        var intentDataDict: [String: Any] = [:]
        
        if let customOrderConfig = SessionManager.currentOrderConfigMeta {
            intentDataDict = [
                "orderConfig": SessionManager.currentOrderConfig?.dictionary as Any,
                "txnConfig": customOrderConfig.dictionary as Any
            ]
        } else {
            intentDataDict = ["orderConfig": SessionManager.currentOrderConfig?.dictionary as Any]
        }
        
        return intentDataDict
    }
    
}
