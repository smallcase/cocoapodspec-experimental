//
//  SCGateway+Utilty.swift
//  SCGateway
//
//  Created by Shivani on 21/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation

internal extension  SCGateway {
    
    func getBrokerConfig(completion: @escaping (Result<[BrokerConfig],NetworkError>) -> Void) {
        
        sessionProvider.request(type: [BrokerConfig].self, service: GatewayService.getBrokerConfig) { (result) in
            completion(result)
        }
    }
    
    func getBrokerTransactionUrl(transactionId: String, brokerConfig: BrokerConfig, isleprechaunActivated: Bool, completion: @escaping(Result<URL, Error>) -> Void) {
        
        
        //Case 1. Non Iframe broker or leprechaun
        if !brokerConfig.isIframePlatform || isleprechaunActivated {
            
            var brokerName = brokerConfig.broker
            
            
            
            var brokerUrlString = "\(brokerConfig.platformURL!)/gatewaytransaction/\(transactionId)"
            
            if (isleprechaunActivated) {
                brokerUrlString = "\(brokerConfig.leprechaunURL!)/gatewaytransaction/\(transactionId)"
                brokerName = brokerName + "-leprechaun"
            }
        
            let params: [URLQueryItem] = [
                
                URLQueryItem(name: "trxid", value: transactionId),
                URLQueryItem(name: "action", value: "gatewaynativetransaction"),
                URLQueryItem(name: "deviceType", value: "iOS"),
                URLQueryItem(name: "broker", value: brokerName ),
                URLQueryItem(name: "gateway", value: Config.gatewayName!)
                
            ]
            var urlComponent = URLComponents(string: brokerUrlString)
            
            urlComponent?.queryItems = params
            
            guard let finalUrl = urlComponent?.url else {
                completion(.failure(TransactionError.invalidUrl))
                return }
            
            completion(.success(finalUrl))
            
        }
            //Case 2. IFrame broker
        else {
            //Make Api calls to fetch params
            
            let stringQueryForRedirectParams = "/gatewaytransaction/\(transactionId)?trxid=\(transactionId)&action=gatewaynativetransaction&deviceType=iOS&gateway=\(Config.gatewayName!)"
            
            getRedirectParams(paramString: stringQueryForRedirectParams, brokerName: brokerConfig.broker) {result in
                switch result {
                case .success(let response):
                    
                    guard let redirectParams = response.data?.redirectParams else {
                        completion(.failure(TransactionError.invalidUrl))
                        return
                    }
                    
                    let urlComponent = URLComponents(string: brokerConfig.baseLoginURL + "?\(redirectParams)" )
                    
                    guard let url = urlComponent?.url else {
                        completion(.failure(TransactionError.invalidUrl))
                        return
                    }
                    
                    completion(.success(url))
                    
                case .failure(let error):
                    print("error: \(error)")
                    completion(.failure(error))
                    
                }
            }
        }
    }
    
      func fetchTransactionStatus(transactionId: String, completion: @escaping(Result<TransactionStatusResponse, TransactionError>) -> Void) {
        
        sessionProvider.request(type: TransactionStatusResponse.self, service: GatewayService.getTransactionStatus(trxid: transactionId)) { [weak self] (result) in
            switch result {
            case .success(let response):
                print(response)
                guard let transaction = response.data?.transaction,
                    self?.getTransactionType(transactionData: transaction) != nil
                    else {
                        completion(.failure(TransactionError.invalidTransactionId))
                        return
                }
                
                // If Transaction Expired
                if transaction.expired != nil && transaction.expired! {
                    completion(.failure(.transactionExpired))
                    return
                }
                
                // For any other error case
                if transaction.error?.value ?? false {
                    completion(.failure(.internalError))
                    return
                }
                completion(.success(response))
                
            case .failure(let error):
                print(error)
                completion(.failure(.internalError))
            }
        }
    }
    
   
    func markTransactionErrored(transactionId: String, error: TransactionError, completion: @escaping(Result<Bool, Error>) -> Void ) {
    
    sessionProvider.request(type: MarkErroredResponse.self, service: GatewayService.markTransactionErrored(trxId: transactionId, error: error)) { (result) in
        switch result {
        case .success(let response):
            print(response)
            completion(.success(response.success))
            
        case .failure(let error):
            completion(.failure(error))
            
        }
    }
}
    
    func checkMarketStatus(completion: @escaping(Result<Bool, Error>) -> Void) {
    
    sessionProvider.request(type: MarketStatusResponse.self, service: GatewayService.marketStatus) { (result) in
        
        switch result {
            
        case .success(let response):
            
            print(response)
            completion(.success(response.data?.marketOpen ?? false || response.data?.amoActive ?? false ))
            
        case .failure(let error):
            
            print(error)
            completion(.failure(error))
            
        }
    }
}
    
    func getGatewayCopy(completion: @escaping(Result<Bool, Error>) -> Void) {
        
        sessionProvider.request(type: [String: GatewayCopyConfig].self, service: GatewayService.getGatewayCopy) { (result) in
            switch result {
            case .success(let response):
                guard let configData = response[Config.gatewayName!] else {
                    Config.copyConfig = response["default"]
                    completion(.success(Config.copyConfig != nil))
                    return
                }
                Config.copyConfig = configData
                completion(.success(true))
                
            case .failure(let error):
                print(error)
                completion(.failure(error))
            }
        }
    }
    
    func getTransactionType(transactionData: Transaction) -> TransactionIntent? {
        
        enum Intent {
            static let INTENT_TRANSACTION = "TRANSACTION"
            static let INTENT_CONNECT = "CONNECT"
            static let INTENT_HOLDINGS = "HOLDINGS_IMPORT"
            }
        
        switch transactionData.intent! {
        case Intent.INTENT_CONNECT:
            
            
            let authToken = transactionData.success.smallcaseAuthToken ?? Config.sdkToken ?? "" 
            return .connect(authToken: authToken, transactionData: transactionData)
           
        case Intent.INTENT_TRANSACTION:
            guard let orderData = transactionData.success.data else { return nil }
            let authToken = transactionData.success.smallcaseAuthToken
            return .transaction(authToken: authToken ?? Config.sdkToken ?? ""
                , transactionData: orderData)
      
        case Intent.INTENT_HOLDINGS:

            guard let authToken = transactionData.success.smallcaseAuthToken ?? transactionData.authId ?? Config.sdkToken else { return nil }
            return .holdingsImport(authToken: authToken, status: transactionData.status!)
         
            
        default:
            return nil
        }
    }
    
    private func getRedirectParams(paramString: String, brokerName: String, completion: @escaping(Result<RedirectURLParamsResponse, NetworkError>) -> Void ) {
        
        sessionProvider.request(type: RedirectURLParamsResponse.self, service: GatewayService.getBrokerRedirectParams(txId: paramString, brokerName: brokerName )) { (result) in
            switch result {
            case .success(let response):
                print(response)
                completion(result)
            case .failure(let error):
                print(error)
                completion(result)
            }
        }
    }

}
