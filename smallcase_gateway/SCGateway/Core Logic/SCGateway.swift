//
//  SCGateway.swift
//  SCGateway
//
//  Created by Shivani on 06/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import UIKit

@objcMembers public class SCGateway: NSObject {
    
    //MARK: Variables
    
    ///Shared Instance
    public static let shared = SCGateway()
    
    public static var currentTransactionId:String = ""
    
    ///Network calls
    internal let sessionProvider = URLSessionProvider()
    
    internal var brokerSelectCoordinator: BrokerSelectCoordinator!
    
    internal var smallplugCoordinator: SmallplugCoordinator!
    
    internal var mfCoordinator: MFCoordinator!
    
    internal var useAccOpeningCoordinator: USEAccOpeningCoordinator!
    
    /// Closure to store any async action to be delayed while a current async call is going on
    internal var pendingRequestClosure: (() -> Void)?
    
    /// To delay execution of other calls if init call is not completed
    internal var isTransactionCallActive = false {
        
        didSet {
            if !isTransactionCallActive {
                guard pendingRequestClosure != nil else { return }
                pendingRequestClosure?()
                pendingRequestClosure = nil
            }
        }
    }
    
    internal var mixpanelSetupInProgress = false
    internal var mixpanelSetupComplete = false
    
    private var webAuthProvider: WebAuthenticationProvider!
    
    //MARK: Methods
    @available(*,deprecated)
    @objc public func setup(config: GatewayConfig) {
        clearConfigs()
        registerAllFonts()
        SessionManager.gatewayName = config.gatewayName
        SessionManager.brokerConfigType = config.brokerConfig
        SessionManager.baseEnvironment = config.apiEnvironment
        SessionManager.isLeprechaunActive = config.isLeprechaunActive
        SessionManager.isAmoEnabled = config.isAmoEnabled
        getGatewayCopy { (result) in
            print(result)
        }
        
        getBrokerConfig { (result) in
            switch result {
                case .success(let brokerConfig):
                    SessionManager.rawBrokerConfig = brokerConfig
                    
                case .failure(let error):
                    print(error)
            }
        }
    }
    
    //MARK: Setup
    @objc public func setup(config: GatewayConfig, completion: ((Bool, Error?) -> Void)?) {
        
        clearConfigs()
        registerAllFonts()
        
        SessionManager.gatewayName = config.gatewayName
        SessionManager.brokerConfigType = config.brokerConfig
        SessionManager.baseEnvironment = config.apiEnvironment
        SessionManager.isLeprechaunActive = config.isLeprechaunActive
        SessionManager.isAmoEnabled = config.isAmoEnabled
        getBrokerConfig { (result) in
            switch result {
                case .success(let brokerConfig):
                    SessionManager.rawBrokerConfig = brokerConfig
                    
                    self.getGatewayCopy() { (result) in
                        switch result {
                            case .success( let bool):
                                if bool {
                                    
                                    self.getMobileConfig { (result) in
                                        switch result {
                                            case .success(let jsonData):
                                                SessionManager.mobileConfig = jsonData.toJson()
                                            
                                            case .failure(let error):
                                                print(error)
                                        }
                                    }
                                    
                                    DispatchQueue.main.async {completion?(true, nil)}
                                } else {
                                    DispatchQueue.main.async {completion?(false, SCGatewayError.configNotSet)}
                                }
                            case .failure(let error):
                                print(error)
                                DispatchQueue.main.async {completion?(false, SCGatewayError.configNotSet)}
                        }
                    }
                    
                case .failure( _):
                    DispatchQueue.main.async {
                        completion?(false, SCGatewayError.configNotSet)
                    }
            }
        }
    }
    
    //MARK: Initialise Gateway SDK
    
    /**
     * - parameter sdkToken : It is a JWT containing broker account identification payload, and signed with the shared secret.
     * It can be created for guest as well as connected users.
     */
    
    @objc public func initializeGateway(_ authToken: String, completion: ((String, Error?) -> Void)?) {
        
        print("SCGATEWAY: -----------> [Initializer triggered]")
        
        guard let _ = SessionManager.gatewayName, let _ = SessionManager.brokerConfigType else {
            DispatchQueue.main.async {completion?("Error", SCGatewayError.configNotSet)}
            return
        }
        
        /// Creates a closure for any incoming async call if init is not completed
        if isTransactionCallActive {
            pendingRequestClosure = { [weak self] in
                self?.initializeGateway(authToken, completion: completion)
                
            }
            return
        }
        
        isTransactionCallActive = true
        
        SessionManager.sdkToken = authToken
        
        sessionProvider.request(type: InitSessionResponse.self, service: GatewayService.initializeSession(smallcaseAuthToken: authToken)) { [weak self] (result) in
            switch result {
                    
                case .success(let response):
                    print(response)
                    
                    guard response.errors?.isEmpty ?? true else {
                        let errors = response.errors
                        // SDK initialised with invalid Gateway name
                        if errors?.contains(TransactionError.invalidGateway.errorValue!) ?? false {
                            DispatchQueue.main.async {completion?("Error", TransactionError.invalidGateway)}
                        }
                        else if errors?.contains(TransactionError.invalidJWT.errorValue!) ?? false {
                            DispatchQueue.main.async {completion?("Error", TransactionError.invalidJWT)}
                        }
                        else {
                            DispatchQueue.main.async {completion?("Success", nil)}
                        }
                        return
                    }
                    //                    Config.gatewayToken = response.data?.gatewayToken
                    
                    SessionManager.csrfToken = response.data?.csrf
                    SessionManager.gateway = response.data
                    SessionManager.userData = response.data?.userData
                    
                    var initResponseDict: [String: Any] = [:]
                    
                    if let gatewayToken = response.data?.gatewayToken {
                        SessionManager.gatewayToken = gatewayToken
                    }
                    
                    if let allowedBrokers = response.data?.allowedBrokers {
                        SessionManager.allowedBrokers = allowedBrokers
                    }
                    
                    if let broker = response.data?.userData?.broker {
                        SessionManager.broker = broker
                        initResponseDict["broker"] = broker.name
                    }
                    
                    if response.data?.userData?.broker?.name?.contains("-leprechaun") ?? false{
                        SessionManager.isLeprechaunActive = true
                    }
                    
                    if let userStatus = response.data?.status {
                        SessionManager.userStatus = UserStatus(rawValue: userStatus)
                        
                        if SessionManager.userStatus == .connected {
                            initResponseDict["User Connected"] = true
                        } else {
                            initResponseDict["User Connected"] = false
                        }
                        
                    } else {
                        SessionManager.userStatus = UserStatus(rawValue: "GUEST")
                        initResponseDict["User Connected"] = false
                    }
                    
                    if let sdkToken = response.data?.smallcaseAuthToken  {
                        SessionManager.sdkToken = sdkToken
                        initResponseDict["smallcaseAuthToken"] = sdkToken
                    }
                    
                    let jsonData = (try? JSONSerialization.data(withJSONObject: initResponseDict, options: []))!
                    
                    let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
                    
                    DispatchQueue.main.async {
                        completion?(jsonString, nil)
                    }
                    
                    
                case .failure(let error):
                    print(error)
                    DispatchQueue.main.async {completion?("Error", nil)}
                    
            }
            print("INIT: call completed" )
            self?.isTransactionCallActive = false
        }
        
    }
    
    /**
     - parameter sdkToken : It is a JWT containing broker account identification payload, and signed with the shared secret.
     It can be created for guest as well as connected users.
     */
    @objc public func initializeGateway(sdkToken: String, completion: ((Bool, Error?) -> Void)? ) {
        
        print("SCGATEWAY: -----------> [Initializer triggered]")
        
        guard let _ = SessionManager.gatewayName, let _ = SessionManager.brokerConfigType else {
            DispatchQueue.main.async {completion?(false, SCGatewayError.configNotSet)}
            return
        }
        
        /// Creates a closure for any incoming async call if init is not completed
        if isTransactionCallActive {
            pendingRequestClosure = { [weak self] in
                self?.initializeGateway(sdkToken: sdkToken, completion: completion)
                
            }
            return
        }
        
        isTransactionCallActive = true
        
        SessionManager.sdkToken = sdkToken
        
        sessionProvider.request(type: InitSessionResponse.self, service: GatewayService.initializeSession(smallcaseAuthToken: sdkToken)) { [weak self] (result) in
            switch result {
                    
                case .success(let response):
                    print(response)
                    
                    guard response.errors?.isEmpty ?? true else {
                        let errors = response.errors
                        // SDK initialised with invalid Gateway name
                        if errors?.contains(TransactionError.invalidGateway.errorValue!) ?? false {
                            DispatchQueue.main.async {completion?(false, TransactionError.invalidGateway)}
                        }
                        else if errors?.contains(TransactionError.invalidJWT.errorValue!) ?? false {
                            DispatchQueue.main.async {completion?(false, TransactionError.invalidJWT)}
                        }
                        else {
                            DispatchQueue.main.async {completion?(true, nil)}
                        }
                        return
                    }
                    if let allowedBrokers = response.data?.allowedBrokers {
                        SessionManager.allowedBrokers = allowedBrokers
                    }
                    SessionManager.gatewayToken = response.data?.gatewayToken
                    SessionManager.csrfToken = response.data?.csrf
                    SessionManager.gateway = response.data
                    SessionManager.broker = response.data?.userData?.broker
                    SessionManager.userData = response.data?.userData
                    
                    if response.data?.userData?.broker?.name?.contains("-leprechaun") ?? false{
                        SessionManager.isLeprechaunActive = true
                    }
                    
                    SessionManager.userStatus = UserStatus(rawValue: response.data?.status ?? "GUEST")
                    
                    if let authToken = response.data?.smallcaseAuthToken  {
                        SessionManager.sdkToken = authToken
                    }
                    
                    DispatchQueue.main.async {completion?(true, nil)}
                    
                    
                case .failure(let error):
                    print(error)
                    DispatchQueue.main.async {completion?(false, nil)}
                    
            }
            print("INIT: call completed" )
            self?.isTransactionCallActive = false
        }
    }
    
    public func triggerTransactionFlow(transactionId: String, presentingController: UIViewController,utmParams:Dictionary<String,String>?,brokerConfig:BrokerConfigType?, completion: @escaping(Result<TransactionIntent, TransactionError>) -> Void) throws {
        
        if brokerConfig == nil {
            SessionManager.brokerConfigType = .defaultConfig
        } else {
            SessionManager.brokerConfigType = brokerConfig!
        }
        
        try triggerTransactionFlow(transactionId: transactionId, presentingController: presentingController,utmParams: utmParams, completion: completion)
        
    }
    
    public func triggerTransactionFlow(transactionId: String, presentingController: UIViewController,utmParams:Dictionary<String,String>?, completion: @escaping(Result<TransactionIntent, TransactionError>) -> Void) throws {
        SessionManager.utmParams = utmParams
        try triggerTransactionFlow(transactionId: transactionId, presentingController: presentingController, completion: completion)
        
    }
    
    //MARK: Trigger Transaction
    
    /**
     * Launches the transactional flow
     * - parameter transactionId : the unique transactionId representing the transaction intended by the user
     * - parameter presentingController : the host app's UiViewController on which the SDK inflates its own UI
     * - parameter completion : handle the SDK response once a transaction is successful / errored
     */
    
    public func triggerTransactionFlow(transactionId: String, presentingController: UIViewController, completion: @escaping(Result<TransactionIntent, TransactionError>) -> Void) throws {
        
        //TODO: refactor this to be used along with Session Manager
        SCGateway.currentTransactionId = transactionId
        SessionManager.currentTransactionId = transactionId
        
        self.setupMixpanel()
        
        /// Throws an error if sdk setup is not performed
        if SessionManager.gatewayName == nil || SessionManager.sdkToken == nil {
            registerMixpanelEvent(
                eventName: MixpanelConstants.EVENT_BP_RESPONSE_TO_PARTNER,
                additionalProperties: [
                    "transactionStatus" : "NA",
                    "intent" : "NA",
                    "transactionId": SessionManager.currentTransactionId ?? "NA",
                    "error_code" : SCGatewayError.uninitialized.errorCode,
                    "error_message" : SCGatewayError.uninitialized.errorMessage
                ])
            
            throw SCGatewayError.uninitialized
        }
        
        /// Creates a closure for any incoming async call if init is not completed
        if isTransactionCallActive {
            pendingRequestClosure = { [weak self] in
                do {
                    try self?.triggerTransactionFlow(transactionId: transactionId, presentingController: presentingController, completion: completion)
                } catch let err {
                    print(err)
                }
            }
            return
        }
        
        var scLoaderViewController: UIViewController? = nil
        DispatchQueue.main.async {
            scLoaderViewController = ScLoadingViewController()
            scLoaderViewController?.modalPresentationStyle = .overFullScreen
            scLoaderViewController?.modalTransitionStyle = .crossDissolve
            presentingController.present(scLoaderViewController!, animated: true)
        }
        
        //Gets the status of the transactionId
        fetchTransactionStatusFirst(transactionId: transactionId) { [weak self] (result) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                scLoaderViewController?.dismiss(animated: true)
                switch result {
                case .success(let response):
                    
                    guard let transaction = response.data?.transaction, let transactionIntent = self?.getTransactionType(transactionData: transaction) else {
                        return
                    }
                    
                    if transaction.status != TransactionOrderStatus.initialized.rawValue {
                        
                        self?.registerMixpanelEvent(
                            eventName: MixpanelConstants.EVENT_BP_RESPONSE_TO_PARTNER,
                            additionalProperties: [
                                "transactionId": SessionManager.currentTransactionId ?? "NA",
                                "transactionStatus": transaction.status ?? "NA",
                                "intent": transaction.intent ?? "NA",
                                "error_code": TransactionError.transactionExpiredBefore.rawValue,
                                "error_message": TransactionError.transactionExpiredBefore.rawValue
                            ])
                        
                        completion(.failure(.transactionExpiredBefore))
                        
                    } else if (transaction.expired ?? false) {
                        
                        self?.registerMixpanelEvent(
                            eventName: MixpanelConstants.EVENT_BP_RESPONSE_TO_PARTNER,
                            additionalProperties: [
                                "transactionStatus": transaction.status ?? "NA",
                                "intent": transaction.intent ?? "NA",
                                "error_code": TransactionError.transactionExpiredBefore.rawValue,
                                "error_message": TransactionError.transactionExpiredBefore.rawValue
                            ])
                        
                        self?.markTransactionErrored(transactionId: transactionId, error: .transactionExpiredBefore){_ in}
                        
                        completion(.failure(.transactionExpiredBefore))
                        
                    } else {
                        
                        self?.checkIfNewUserHasInitiatedTransaction(authId: transaction.authId)
                        self?.registerSessionData(transaction: response.data?.transaction)
                        
                        SessionManager.currentIntent = transactionIntent
                        
                        switch transactionIntent {
                            
                        case .connect:
                            
                            if SessionManager.userStatus == .connected {
                                
                                ///If the user is already connected, do not trigger the transaction (edge case)
                                
                                self?.registerMixpanelEvent(
                                    eventName: MixpanelConstants.EVENT_BP_RESPONSE_TO_PARTNER,
                                    additionalProperties: [
                                        "transactionId": SessionManager.currentTransactionId ?? "NA",
                                        "intent": "CONNECT",
                                        "transactionStatus": transaction.status ?? "NA",
                                        "error_code": "NA",
                                        "error_message": "NA"
                                    ])
                                
                                let alreadyConnectedResponse = [
                                    "smallcaseAuthToken" : SessionManager.sdkToken,
                                    "broker": SessionManager.broker?.name ?? ""
                                ]
                                
                                completion(.success(.connect(response: alreadyConnectedResponse.toJSONString())))
                                return
                            } else {
                                self?.openBrokerSelect(presentingController, transactionId,true ,completion: completion)
                            }
                            
                        case .transaction:
                            
                            /// Check if market is open
                            
                            if (SessionManager.broker != nil && SessionManager.shouldCheckMarketStatus()) {
                                self?.checkMarketStatus(completion: { [weak self] (result) in
                                    switch result {
                                    case .success(let isOpen):
                                        
                                        if !isOpen {
                                            
                                            ///Market is closed
                                            
                                            self?.updateBroker(tranxId: transactionId, broker: SessionManager.broker?.name ?? "", isLeprechaun: SessionManager.isLeprechaunActive)
                                            
                                            self?.markTransactionErrored(transactionId: transactionId, error: .marketClosed){_ in}
                                            
                                            
                                            ///Track market closed status on mixpanel
                                            
                                            self?.registerMixpanelEvent(
                                                eventName: MixpanelConstants.EVENT_BP_RESPONSE_TO_PARTNER,
                                                additionalProperties: [
                                                    "transactionId": SessionManager.currentTransactionId ?? "NA",
                                                    "transactionStatus": transaction.status ?? "NA",
                                                    "intent": transaction.intent ?? "NA",
                                                    "error_code": TransactionError.marketClosed.rawValue,
                                                    "error_message": TransactionError.marketClosed.message
                                                ])
                                            
                                            completion(.failure(.marketClosed))
                                            return
                                        }
                                        
                                        // Triggers BrokerSelect Coordinator
                                        
                                        self?.openBrokerSelect(presentingController, transactionId, true,completion: completion)
                                        
                                    case .failure(let error):
                                        
                                        print(error)
                                        
                                        self?.registerMixpanelEvent(eventName: MixpanelConstants.EVENT_BP_RESPONSE_TO_PARTNER, additionalProperties: [
                                            "transactionStatus": "NA",
                                            "intent": "NA",
                                            "transactionId": SessionManager.currentTransactionId ?? "NA",
                                            "error_code": TransactionError.apiError.rawValue,
                                            "error_message": TransactionError.apiError.message
                                        ])
                                        
                                        completion(.failure(.apiError))
                                        
                                        return
                                    }
                                })
                            } else {
                                self?.openBrokerSelect(presentingController, transactionId,true ,completion: completion)
                            }
                            
                        case .mfHoldingsImport(_):
                            
                            DispatchQueue.main.async { [weak self] in
                                
                                self?.mfCoordinator = MFCoordinator(presentingViewController: presentingController,transactionId: transactionId, completion: completion)
                                self?.mfCoordinator.start()
                            }
                        default:
                            self?.openBrokerSelect(presentingController, transactionId,false ,completion: completion)
                        }
                    }
                    
                        
                    case .failure(let error):
                        
                        if error == .transactionExpired {
                            
                            self?.registerMixpanelEvent(
                                eventName: MixpanelConstants.EVENT_BP_RESPONSE_TO_PARTNER,
                                additionalProperties: [
                                    "error_code": TransactionError.transactionExpiredBefore.rawValue,
                                    "error_message": TransactionError.transactionExpiredBefore.rawValue,
                                    "intent": SessionManager.currentIntentString ?? "NA",
                                    "transactionId": SessionManager.currentTransactionId ?? "NA",
                                    "transactionStatus": "NA",
                                ])
                            
                            self?.markTransactionErrored(transactionId: transactionId, error: .transactionExpiredBefore){_ in}
                            completion(.failure(.transactionExpiredBefore))
                        } else {
                            completion(.failure(error))
                        }
                        
                        print(error)
                        
                }
            }
        }
        
        updateDeviceType(tranxId: transactionId, device: "ios")
        
    }
    
    private func openBrokerSelect(_ presentingController: UIViewController,_ transactionId: String,_ transactionIntent:Bool, completion: @escaping (Result<TransactionIntent, TransactionError>) -> Void ) {
        
        registerMixpanelEvent(eventName: MixpanelConstants.EVENT_TRANSACTION_TRIGGERED, additionalProperties: [
            "authId": SessionManager.smallcaseAuthId ?? "NA",
            "intent": SessionManager.currentIntentString ?? "NA",
            "transactionId": SessionManager.currentTransactionId ?? "NA",
            "transactionStatus": SessionManager.currentTransactionIdStatus?.status ?? "NA"
        ])
        
        DispatchQueue.main.async {[weak self] in
            self?.brokerSelectCoordinator = BrokerSelectCoordinator(presentingViewController: presentingController, transactionId: transactionId,transactionIntent: transactionIntent, completion: completion)
            self?.brokerSelectCoordinator.start()
        }
        
    }
    
    //MARK: Public Utility
    @objc public func isUserConnected() -> Bool {
        
        if SessionManager.gatewayName != nil && SessionManager.sdkToken != nil {
            return SessionManager.userStatus == .connected
        } else {
            return false
        }
        
    }
    
    @objc public func getUserAuthToken() -> String? {
        
        return SessionManager.sdkToken
    }
    
    @objc public func setSDKType(type: String) {
        SessionManager.sdkType = type
    }
    
    @objc public func setHybridSDKVersion(version: String) {
        SessionManager.hybridSDKVersion = version
    }
    
    @objc public func getSdkVersion() -> String {
        let version = Bundle.init(for: SCGateway.self).infoDictionary!["CFBundleShortVersionString"]!
        return String(describing: version)
    }
    
    
    //MARK: Native Broker Login
    
    @objc public func handleBrokerRedirection(redirectUrl: URL) {
        print("------------------- Processing Transaction Post External App's Redirection ------------------------------")
        
        guard
            SessionManager.gatewayName != nil,
            let components = NSURLComponents(url: redirectUrl, resolvingAgainstBaseURL: true),
            let host = components.host, NativeLoginConstants.FIRST_PARTY_UNIVERSAL_LINKS.contains(host),
            let brokerSelectCoordinator = self.brokerSelectCoordinator else {
            return
        }
        
        if let transactionId = SessionManager.currentTransactionId, !SessionManager.showOrders {
            
            fetchTransactionStatus(transactionId: transactionId) { (result) in
                
                switch result {
                        
                    case .success(let response):
                        
                        guard let transaction = response.data?.transaction else {
                            return
                        }
                        
                        if transaction.status != TransactionOrderStatus.initialized.rawValue {
                            return
                        }
                        
                        brokerSelectCoordinator.handleNativeLoginRedirection(redirectUrl)
                        
                    case .failure(let error):
                        print(error)
                        return
                        
                }
            }
        }
        
        if (SessionManager.showOrders) {
            brokerSelectCoordinator.handleNativeLoginRedirection(redirectUrl)
        }
    }
    
}

