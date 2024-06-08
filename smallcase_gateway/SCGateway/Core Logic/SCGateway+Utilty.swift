//
//  SCGateway+Utilty.swift
//  SCGateway
//
//  Created by Shivani on 21/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation

internal extension SCGateway {
    
    func getMobileConfig(completion: @escaping (Result<Data, Error>) -> Void) {
    
        sessionProvider.requestJson(service: GatewayService.getMobileConfig) { (result) in
            completion(result)
        }
    }
    
    func getBrokerConfig(completion: @escaping (Result<[BrokerConfig],NetworkError>) -> Void) {
        
        sessionProvider.request(type: [BrokerConfig].self, service: GatewayService.getBrokerConfig) { (result) in
            completion(result)
        }
    }
    
    func getLogoutUrl(brokerConfig:BrokerConfig, isleprechaunActivated:Bool, completion: @escaping(Result<URL, Error>) -> Void) {
        //Case 1. Non Iframe broker or leprechaun
        if !brokerConfig.isIframePlatform || isleprechaunActivated {
            
            var brokerName = brokerConfig.broker
            var brokerUrlString = "\(brokerConfig.platformURL!)/brokerLogout"
            
            if (isleprechaunActivated) {
                brokerUrlString = "\(brokerConfig.leprechaunURL!)/brokerLogout"
                brokerName = brokerName + "-leprechaun"
            }
            
            var params: [URLQueryItem] = [
                URLQueryItem(name: "action", value: "gatewaynativetransaction"),
                URLQueryItem(name: "deviceType", value: "iOS"),
                URLQueryItem(name: "broker", value: brokerName ),
                URLQueryItem(name: "gateway", value: SessionManager.gatewayName!),
                URLQueryItem(name: "v", value: SCGateway.shared.getSdkVersion()),
                URLQueryItem(name: "gatewayName", value: SessionManager.gateway!.displayName!)
            ]
            
            if SessionManager.baseEnvironment == .staging {
                params.append(URLQueryItem(name: "staging",value: "true"))
            }
            
            if SessionManager.utmParams != nil {
                for (key, value) in SessionManager.utmParams! {
                    params.append(URLQueryItem(name: key, value: value))
                }
            }
            
            var urlComponent = URLComponents(string: brokerUrlString)
            
            urlComponent?.queryItems = params
            
            guard let finalUrl = urlComponent?.url else {
                completion(.failure(TransactionError.invalidUrl))
                return }
            //                   print(finalUrl)
            
            completion(.success(finalUrl))
            
        }
        //Case 2. IFrame broker
        else {
            //Make Api calls to fetch params
            
            let stringQueryForRedirectParams = "/brokerLogout?action=gatewaynativetransaction&deviceType=iOS&v=\(SCGateway.shared.getSdkVersion())&gateway=\(SessionManager.gatewayName!)"
            
            getRedirectParams(paramString: stringQueryForRedirectParams, brokerName: brokerConfig.broker) {result in
                switch result {
                    case .success(let response):
                        guard let redirectParams = response.data?.redirectParams else {
                            completion(.failure(TransactionError.invalidUrl))
                            return
                        }
                        
                        var urlComponent = URLComponents(string: brokerConfig.baseLoginURL + "?\(redirectParams)" )
                        
                        if SessionManager.utmParams != nil {
                            var params: [URLQueryItem] = urlComponent?.queryItems ?? []
                            
                            for (key, value) in SessionManager.utmParams! {
                                params.append(URLQueryItem(name: key, value: value))
                            }
                            urlComponent?.queryItems = params
                        }
                        if SessionManager.baseEnvironment == .staging {
                            var params: [URLQueryItem] = urlComponent?.queryItems ?? []
                            params.append(URLQueryItem(name: "staging",value: "true"))
                            urlComponent?.queryItems = params
                        }
                        
                        guard let url = urlComponent?.url else {
                            completion(.failure(TransactionError.invalidUrl))
                            return
                        }
                        
                        //                           print(url)
                        completion(.success(url))
                        
                    case .failure(let error):
                        print("error: \(error)")
                        completion(.failure(error))
                        
                }
            }
        }
    }
    
    /*
     Get the URL for SHOW_ORDERS for the broker in brokerConfig object
     handles the leprechaun user's URL specifically.
     */
    func getShowOrdersUrl(brokerConfig: BrokerConfig, isleprechaunActivated:Bool, isNativeLoginEnabled: Bool, completion: @escaping(Result<URL, Error>) -> Void) {
        
        var broker = brokerConfig.broker
        
        if isleprechaunActivated {
            broker.append("-leprechaun")
        }
        
        var stringQueryForRedirectParams = "/orders?action=gatewaynativetransaction&deviceType=iOS&v=\(SCGateway.shared.getSdkVersion())&broker=\(broker)"
        
        if SessionManager.baseEnvironment == .staging {
            stringQueryForRedirectParams.append("&staging=true")
        }
        
        getRedirectParams(paramString: stringQueryForRedirectParams, brokerName: brokerConfig.broker) {result in
            switch result {
                case .success(let response):
                    
                    guard let redirectParams = response.data?.redirectParams else {
                        completion(.failure(TransactionError.invalidUrl))
                        return
                    }
                    
                    var urlComponent = URLComponents(string: brokerConfig.platformURL! + stringQueryForRedirectParams)
                    
                    if isleprechaunActivated {
                        urlComponent = URLComponents(string: brokerConfig.leprechaunURL! + stringQueryForRedirectParams)
                    } else {
                        
                        if brokerConfig.isIframePlatform {
                            urlComponent = URLComponents(string: brokerConfig.platformURL! + "/?\(redirectParams)" )
                        } else {
                            urlComponent = URLComponents(string: brokerConfig.platformURL! + stringQueryForRedirectParams)
                        }
                    }
                    
                    var params: [URLQueryItem] = urlComponent?.queryItems ?? []
                    
                    if SessionManager.baseEnvironment == .staging {
                        params.append(URLQueryItem(name: "staging",value: "true"))
                    }
                    
                    params.append(URLQueryItem(name: "gateway", value: SessionManager.gatewayName!))
                    params.append(URLQueryItem(name: "gatewayName", value: SessionManager.gateway!.displayName!))
                    params.append(URLQueryItem(name: "nativeLoginEnabled", value: isNativeLoginEnabled.description))
                    
                    urlComponent?.queryItems = params
                    
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
    
    func getBrokerTransactionUrl(transactionId: String, brokerConfig: BrokerConfig, isleprechaunActivated: Bool, isNativeLoginEnabled: Bool, completion: @escaping(Result<URL, Error>) -> Void) {
        
        if brokerConfig.gatewayLoginConsent == nil {
            updateBroker(tranxId: transactionId, broker: brokerConfig.broker, isLeprechaun: isleprechaunActivated)
        }
        
        //Case 1. Non Iframe broker or leprechaun
        if !brokerConfig.isIframePlatform || isleprechaunActivated {
            
            var brokerName = brokerConfig.broker
            
            var brokerUrlString = "\(brokerConfig.platformURL!)/gatewaytransaction/\(transactionId)"
            
            if (isleprechaunActivated) {
                brokerUrlString = "\(brokerConfig.leprechaunURL!)/gatewaytransaction/\(transactionId)"
                brokerName = brokerName + "-leprechaun"
            }
            
            var params: [URLQueryItem] = [
                URLQueryItem(name: "trxid", value: transactionId),
                URLQueryItem(name: "action", value: "gatewaynativetransaction"),
                URLQueryItem(name: "deviceType", value: "iOS"),
                URLQueryItem(name: "broker", value: brokerName ),
                URLQueryItem(name: "gateway", value: SessionManager.gatewayName!),
                URLQueryItem(name: "v", value: SCGateway.shared.getSdkVersion()),
                URLQueryItem(name: "nativeLoginEnabled", value: isNativeLoginEnabled.description),
                URLQueryItem(name: "intent", value: SessionManager.currentIntentString),
                URLQueryItem(name: "gatewayName", value: SessionManager.gateway!.displayName!)
            ]
            
            if SessionManager.baseEnvironment == .staging {
                params.append(URLQueryItem(name: "staging",value: "true"))
            }
            
            if SessionManager.utmParams != nil {
                for (key, value) in SessionManager.utmParams! {
                    params.append(URLQueryItem(name: key, value: value))
                }
            }
            var urlComponent = URLComponents(string: brokerUrlString)
            
            urlComponent?.queryItems = params
            
            guard let finalUrl = urlComponent?.url else {
                completion(.failure(TransactionError.invalidUrl))
                return }
            //            print(finalUrl)
            
            completion(.success(finalUrl))
            
        }
        //Case 2. IFrame broker like HDFC, Axis
        else {
            //Make Api calls to fetch params
            
            let stringQueryForRedirectParams = "/gatewaytransaction/\(transactionId)?trxid=\(transactionId)&action=gatewaynativetransaction&deviceType=iOS&v=\(SCGateway.shared.getSdkVersion())&gateway=\(SessionManager.gatewayName!)"
            
            getRedirectParams(paramString: stringQueryForRedirectParams, brokerName: brokerConfig.broker) {result in
                switch result {
                    case .success(let response):
                        
                        guard let redirectParams = response.data?.redirectParams else {
                            completion(.failure(TransactionError.invalidUrl))
                            return
                        }
                        
                        var urlComponent = URLComponents(string: brokerConfig.baseLoginURL + "?\(redirectParams)%26nativeLoginEnabled%3D\(SessionManager.nativeBrokerLoginEnabled)%26intent%3D\(SessionManager.currentIntentString ?? "")")
                        
                        if SessionManager.baseEnvironment == .staging {
                            urlComponent = URLComponents(string: brokerConfig.baseLoginURL + "?\(redirectParams)%26staging%3Dtrue%26nativeLoginEnabled%3D\(SessionManager.nativeBrokerLoginEnabled)%26intent%3D\(SessionManager.currentIntentString ?? "")")
                        }
                        
                        if SessionManager.utmParams != nil {
                            var params: [URLQueryItem] = urlComponent?.queryItems ?? []
                            
                            for (key, value) in SessionManager.utmParams! {
                                params.append(URLQueryItem(name: key, value: value))
                            }
                            urlComponent?.queryItems = params
                        }
                        
                        guard let url = urlComponent?.url else {
                            completion(.failure(TransactionError.invalidUrl))
                            return
                        }
                        
                        //                    print(url)
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
                    guard let transaction = response.data?.transaction
                    else {
                        completion(.failure(TransactionError.invalidTransactionId))
                        return
                        
                    }
                    
                    //                    if transaction.expired != nil && transaction.expired!{
                    //                        completion()
                    //                        return
                    //
                    //                    }
                    
                    guard self?.getTransactionType(transactionData: transaction) != nil else {
                        completion(.failure(.invalidTransactionId))
                        return
                    }
                    
                    completion(.success(response))
                    
                case .failure(let error):
                    print(error)
                    completion(.failure(.apiError))
            }
        }
    }
    
    func fetchMfTransactionStatus(transactionId: String, completion: @escaping ((Result<MFTransactionStatusResponse, TransactionError>) -> Void)) -> Void {
        sessionProvider.request(type: MFTransactionStatusResponse.self, service: GatewayService.getTransactionStatus(trxid: transactionId)) { (result) in
            switch result {
                case .success(let response):
                    print(response)
                    guard (response.data?.transaction) != nil
                    else {
                        completion(.failure(TransactionError.invalidTransactionId))
                        return
                    }
                    completion(.success(response))
                case .failure(let error):
                    print(error)
                    completion(.failure(.apiError))
            }
        }
    }
    
    func fetchTransactionStatusFirst(transactionId: String, completion: @escaping(Result<TransactionStatusResponse, TransactionError>) -> Void) {
        
        sessionProvider.request(type: TransactionStatusResponse.self, service: GatewayService.getTransactionStatus(trxid: transactionId)) { [weak self] (result) in
            switch result {
                case .success(let response):
                    print(response)
                    guard let transaction = response.data?.transaction
                    else {
                        if response.errorType == "InputException" {
                            completion(.failure(TransactionError.invalidTransactionId))
                        } else {
                            completion(.failure(TransactionError.apiError))
                        }
                        
                        return
                    }
                    
                    
                    guard self?.getTransactionType(transactionData: transaction) != nil else {
                        completion(.failure(.apiError))
                        return
                    }
                    completion(.success(response))
                    
                case .failure(let error):
                    print(error)
                    completion(.failure(.apiError))
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
                    completion(.success(response.data?.marketOpen ?? false || (response.data?.amoActive ?? false && SessionManager.isAmoEnabled)))
                    
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
                    guard let configData = response[SessionManager.gatewayName!] else {
                        SessionManager.copyConfig = response["default"]
                        completion(.success(SessionManager.copyConfig != nil))
                        return
                    }
                    SessionManager.copyConfig = configData
                    completion(.success(true))
                    
                case .failure(let error):
                    print(error)
                    completion(.failure(error))
            }
        }
    }
    
    
    func getPartnerCopy(completion: @escaping(Result<Bool, Error>) -> Void) {
        
        sessionProvider.request(type: [String: GatewayCopyConfig].self, service: GatewayService.getPartnerConfig) { (result) in
            switch result {
                case .success(let response):
                    print(response)
                    guard let configData = response["copyConfig"] else {
                        completion(.success(SessionManager.copyConfig != nil))
                        return
                    }
                    SessionManager.copyConfig = configData
                    completion(.success(SessionManager.copyConfig != nil))
                    
                case .failure(let error):
                    print(error)
                    completion(.failure(error))
            }
        }
    }
    
    func getTweetConfig(completion: @escaping(Result<Bool, Error>) -> Void) {
        sessionProvider.request(type: UpcomingBrokerConfig.self, service: GatewayService.getTweetConfig){ (result) in
            switch result {
                case .success(let response):
                    print(response)
                    SessionManager.tweetConfig = response.upcomingBrokers
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
            static let ONBOARDING = "ONBOARDING"
            static let INTENT_HOLDINGS = "HOLDINGS_IMPORT"
            static let AUTHORISE_HOLDINGS = "AUTHORISE_HOLDINGS"
            static let FETCH_FUNDS = "FETCH_FUNDS"
            static let SIP_SETUP = "SIP_SETUP"
            static let SUBSCRIPTION = "SUBSCRIPTION"
            static let CANCEL_AMO = "CANCEL_AMO"
            static let MF_HOLDINGS_IMPORT = "MF_HOLDINGS_IMPORT"
        }
        
        let authToken = transactionData.success.smallcaseAuthToken ?? SessionManager.sdkToken ?? ""
        let broker = transactionData.success.broker ?? SessionManager.currentBroker ?? ""
        let signup = transactionData.success.signup
        let transactionId = transactionData.transactionId ?? ""
        
        var genericResponseDict: [String: Any] = [
            "smallcaseAuthToken": authToken,
            "broker": broker,
            "transactionId": transactionId
        ]
        
        if let signup = signup {
            genericResponseDict["signup"] = signup
        }
        
        
        switch transactionData.intent! {
                
            case Intent.SUBSCRIPTION:
                
                return .subscription(genericResponseDict.toJsonString!)
            
        case Intent.ONBOARDING:
            return .onboarding(response: genericResponseDict.toJsonString!)
                
            case Intent.INTENT_CONNECT:
                
                return .connect(response: genericResponseDict.toJsonString!)
                
            case Intent.INTENT_HOLDINGS:
                
                return .holdingsImport(smallcaseAuthToken: authToken, broker: broker, status: true, transactionId: transactionId, signup: signup)
                
            case Intent.AUTHORISE_HOLDINGS:
                
                return .authoriseHoldings(smallcaseAuthToken: authToken, status: true,transactionId: transactionId, signup: signup)
                
            case Intent.INTENT_TRANSACTION:
                
                let orderData = transactionData.success
                return .transaction(smallcaseAuthToken: authToken, transactionData: orderData)
                
            case Intent.SIP_SETUP:
                //                let sipAction = transactionData.success.data?.sipDetails ?? SipDetail(sipActive: nil, sipAction: nil, amount: nil, frequency: nil, iscid: nil, scheduledDate: nil, scid: nil, sipType: nil)
                
                let sipAction = transactionData.success.data?.sipDetails ?? SipDetail()
                return .sipSetup(smallcaseAuthToken: authToken, sipAction: sipAction, transactionId: transactionId, signup: signup)
                
            case Intent.FETCH_FUNDS:
                
                let funds = transactionData.success.data?.funds ?? 0.0
                return .fetchFunds(smallcaseAuthToken: authToken, fund: funds, transactionId: transactionId, signup: signup)
                
            case Intent.CANCEL_AMO:
                
                return .cancelAMO(transactionData.success.toJSONString())
                
            case Intent.MF_HOLDINGS_IMPORT:
                return .mfHoldingsImport(data: nil)
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
    
    func updateBroker(tranxId:String , broker: String, isLeprechaun: Bool){
        var sanitizedBroker = broker
        if isLeprechaun && !sanitizedBroker.contains("-leprechaun"){
            sanitizedBroker = "\(broker)-leprechaun"
        }
        
        sessionProvider.request(type: UpdateDeviceResponse.self, service: GatewayService.updateBroker(trnxId: tranxId, broker: sanitizedBroker)){res in
            print(res)
        }
    }
    
    func updateDeviceType(tranxId:String , device: String){
        sessionProvider.request(type: UpdateDeviceResponse.self, service: GatewayService.updateDeviceType(trnxId: tranxId, device: device)){res in
            print(res)
        }
    }
    
    func updateConsent(tranxId:String){
        sessionProvider.request(type: UpdateDeviceResponse.self, service: GatewayService.updateConsent(trnxId: tranxId)){ res in
            print(res)
        }
    }
    
    func getFivePaisaLeadAuthToken(email: String, source: String, completion: @escaping(Result<FivePaisaLeadAuthResponse, NetworkError>) -> Void) {
        sessionProvider.request(type: FivePaisaLeadAuthResponse.self, service: GatewayService.getFivePaisaLead(email: email, source: source)) { result in
            
            switch result {
                case .success(let fivePaisaLeadGenToken):
                    print(fivePaisaLeadGenToken)
                    completion(result)
                case .failure(let error):
                    print(error)
                    completion(result)
            }
        }
    }
    
    func registerAllFonts() {
        UIFont.jbs_registerFont(
            withFilenameString: "GraphikApp-Bold.ttf",
            bundle: Bundle(for: SCGateway.self)
        )
        UIFont.jbs_registerFont(
            withFilenameString: "GraphikApp-Light.ttf",
            bundle: Bundle(for: SCGateway.self)
        )
        UIFont.jbs_registerFont(
            withFilenameString: "GraphikApp-Medium.ttf",
            bundle: Bundle(for: SCGateway.self)
        )
        UIFont.jbs_registerFont(
            withFilenameString: "GraphikApp-MediumItalic.ttf",
            bundle: Bundle(for: SCGateway.self)
        )
        UIFont.jbs_registerFont(
            withFilenameString: "GraphikApp-Regular.ttf",
            bundle: Bundle(for: SCGateway.self)
        )
        UIFont.jbs_registerFont(
            withFilenameString: "GraphikApp-RegularItalic.ttf",
            bundle: Bundle(for: SCGateway.self)
        )
        UIFont.jbs_registerFont(
            withFilenameString: "GraphikApp-Semibold.ttf",
            bundle: Bundle(for: SCGateway.self)
        )
        //        for family: String in UIFont.familyNames
        //               {
        //                   print("\(family)")
        //                   for names: String in UIFont.fontNames(forFamilyName: family)
        //                   {
        //                          print("== \(names)")
        //                   }
        //               }
    }
    
    func registerSessionData(transaction: Transaction?) {
        
        SessionManager.currentIntentString = transaction?.intent
        SessionManager.currentSubscriptionConfig = transaction?.subscriptionConfig
        SessionManager.currentOrderConfig = transaction?.orderConfig
        SessionManager.currentOrderConfigMeta = transaction?.config
        SessionManager.currentBroker = transaction?.success.broker
        SessionManager.type = transaction?.orderConfig?.type
        SessionManager.currentTransactionIdStatus = transaction
    }
    
    func clearConfigs() {
        SessionManager.brokerConfig = []
        SessionManager.moreBrokers = []
        SessionManager.rawBrokerConfig = []
        SessionManager.tweetConfig = []
        SessionManager.copyConfig = nil
        SessionManager.broker = nil
        SessionManager.isLeprechaunActive = false
        SessionManager.utmParams = nil
        SessionManager.currentIntent = nil
        SessionManager.type = nil
        SessionManager.nativeBrokerLoginEnabled = false
    }
    
    
    /// Checks if the SDK already has a connected user and if so, is the connected user different from the one initiating a transaction
    /// - Parameter authId: The smallcaseAuthId of the user (this can be different than the one present in SDK).
    func checkIfNewUserHasInitiatedTransaction(authId: String?) {
        
        if let currentUserAuthId = authId {
            
            SessionManager.smallcaseAuthId = currentUserAuthId
            self.identifyUser(currentUserAuthId)
            
            if let storedAuthId = UserDefaults.standard.string(forKey: "smallcaseAuthId"), currentUserAuthId != storedAuthId {
                self.setupMixpanelForANewUser(currentUserAuthId)
            }
        }
    }
    
    func isSDKInitialised() -> Bool {
        return SessionManager.gatewayName != nil && SessionManager.sdkToken != nil
    }
}
