//
//  BrokerSelectViewModel.swift
//  SCGateway
//
//  Created by Shivani on 06/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import AuthenticationServices
import UIKit

class BrokerSelectViewModel: NSObject, BrokerSelectViewModelProtocol, LeadGenControllerDelegate {
    
    //MARK: Variables
    
    // Transaction Related
    internal var webAuthCompletionUrl: URL?
    
    internal var webAuthCompletionError: Error?
    
    internal var transactionId: String
    
    internal var model: BrokerSelectModelProtocol?
    
    internal  weak var delegate: BrokerSelectVMDelegate?
    
    //    internal weak var upcomingBrokerSelectedDelegate: SelectUpcomingBrokerDelegate?
    
    internal weak var coordinatorDelegate: BrokerSelectCoordinatorVMDelegate?
    
    internal var transactionIntent:Bool
    
    internal var selectedUpComingBroker:UpcomingBroker? = nil
    
    internal var isLogout: Bool = false
    
    internal var showOrders: Bool = SessionManager.showOrders
    
    private var pollAttemptedForOrderRequest = 0
    
    // Wrappers for web auth session
    internal var webAuthProvider: WebAuthenticationProvider!
    
    //    @available(iOS 13.0, *)
    internal lazy var gatewayAuthProvider: Any? = nil
    
    //    @available(iOS 13.0, *)
    internal lazy var webPresentationContextProvider: Any? = nil
    
    // Gets set Whenever user selects a config (from broker chooser)
    internal var userBrokerConfig: BrokerConfig? {
        
        didSet {
            
            SessionManager.userBrokerConfig = userBrokerConfig
            
            if self.isLogout {
                initiateLogoutWebView()
            } else if SessionManager.showOrders {
                initiateShowOrdersWebView()
            } else {
                triggerFlowBasedOnSelectedBrokerConfig()
            }
        }
    }
    
    internal var customPopupKeyboarddelegate: KeyboardAppearDelegate? = nil
    
    internal var leprechaunActivated: Bool {
        get {
            return SessionManager.isLeprechaunActive
        }
        set {
            SessionManager.isLeprechaunActive = newValue
            delegate?.leprechaunStateChanged()
        }
    }
    
    // For Polling transaction status (in case of pending transaction processing )
    // Is true when polling ongoing
    private var pollingTransactionStatus = false
    
    // number of times the request has to be polled
    private var pollingRequestsRemaining = Constants.MAX_POLL_COUNT
    
    private var pollingReqestsRemainingHoldings = Constants.MAX_POLL_HOLDINGS
    
    // Broker Config for all brokers
    private var config: [BrokerConfig]? {
        didSet {
            
            guard let config = config else { return }
            
            if config.count == 0 {
                
                self.handleError(SessionManager.currentTransactionIdStatus, .noBrokerError)
                self.coordinatorDelegate?.logoutFailed(error: TransactionError.noBrokerError)
                
            } else {
                
                let connectedBroker = getConnectedBrokerConfig(brokersConfigArray: config)
                
                if connectedBroker?.gatewayLoginConsent != nil {
                    updateBroker(brokerConfig: connectedBroker!)
                    delegate?.changeState(to: .connectedConsent(brokerConfig: connectedBroker!), completion: nil)
                } else {
                    userBrokerConfig = connectedBroker
                }
            }
        }
    }
    
    // MARK: Initialization
    
    required init(model: BrokerSelectModelProtocol, transactionId: String,transactionIntent:Bool) {
        self.model = model
        self.transactionId = transactionId
        self.transactionIntent = transactionIntent
        self.isLogout = false
        self.showOrders = false
    }
    
    init(isLogout:Bool,model:BrokerSelectModelProtocol) {
        self.model = model
        self.isLogout = isLogout
        self.transactionId = ""
        self.transactionIntent = false
        self.showOrders = false
    }
    
    init(showOrders: Bool, model: BrokerSelectModelProtocol) {
        SessionManager.showOrders = showOrders
        self.model = model
        self.isLogout = false
        self.transactionId = ""
        self.transactionIntent = false
    }
    
    func clickedDismiss() {
        self.handleError(SessionManager.currentTransactionIdStatus, .closedBrokerChooser)
    }
    
    func consentGiven(brokerConfig: BrokerConfig) {
        SCGateway.shared.updateConsent(tranxId: transactionId)
        userBrokerConfig = brokerConfig
    }
    
    func keyboardAppeared(height: CGFloat) {
        customPopupKeyboarddelegate?.keyboardAppeared(height: height)
    }
    
    func KeyboardDisappeared() {
        customPopupKeyboarddelegate?.keyboardDisapeared()
    }
    
    internal func config(at index: Int) -> BrokerConfig? {
        return config?[index]
    }
    
    internal func getBrokerConfig() {
        
        self.model?.getBrokerData(completion: { [weak self] (result) in
            switch result {
                case .success(let config):
                    
                    if SessionManager.showOrders && config.count == 0 {
                        
                        SCGateway.shared.registerMixpanelEvent(
                            eventName: MixpanelConstants.EVENT_BP_RESPONSE_TO_PARTNER,
                            additionalProperties: [
                                "transactionId": SessionManager.currentTransactionId ?? "NA",
                                "transactionStatus": SessionManager.currentTransactionIdStatus?.status ?? "NA",
                                "intent": "show_orders",
                                "error_code": TransactionError.intentNotEnabledForBroker.rawValue,
                                "error_message": TransactionError.intentNotEnabledForBroker.message
                            ])
                        
                        self?.coordinatorDelegate?.nonTransactionalIntentCompleted(success: false, error: ObjcTransactionError(error: .intentNotEnabledForBroker))
                        
                    } else {
                        self?.config = config
                        SessionManager.brokerConfig = config
                    }
                    
                case .failure(let error):
                    print("BROKER CONFIG ERROR: \(error)")
            }
        })
    }
    
    internal func getAvailableBrokers() -> [String]? {
        
        if let allowedBrokers = self.model?.getAllowedBrokers() {
            return allowedBrokers
        } else {
            return nil
        }
    }
    
    //Checks and returns a valid broker if already selected
    func getConnectedBrokerConfig (brokersConfigArray: [BrokerConfig]) -> BrokerConfig? {
        
        var absoluteBrokerName = SessionManager.broker?.name
        
        if let broker = SessionManager.broker {
            if broker.name?.contains(Constants.leprechaunPostFix) ?? false {
                if !leprechaunActivated {
                    leprechaunActivated = true
                }
                
                absoluteBrokerName = broker.name?.replacingOccurrences(of: Constants.leprechaunPostFix, with: "")
            }
        }
        
        var matchedBrokerConfigList =  brokersConfigArray.filter({ (item) -> Bool in
            item.broker == absoluteBrokerName
        })
        
        if matchedBrokerConfigList.isEmpty && !SessionManager.moreBrokers.isEmpty {
            matchedBrokerConfigList =  SessionManager.moreBrokers.filter({ (item) -> Bool in
                item.broker == absoluteBrokerName
            })
        }
        
        if matchedBrokerConfigList.isEmpty  {return nil}
        return matchedBrokerConfigList[0]
        
    }
    
    /// Checks if the user has any broker sets
    private func triggerFlowBasedOnSelectedBrokerConfig() {
        
        // removes leprechaun substring if set
        if let userBrokerConfig = self.userBrokerConfig {
            
            if(transactionIntent) {
                if SessionManager.currentIntentString == "CONNECT" {
                    delegate?.changeState(to: .preConnect(brokerConfig: userBrokerConfig), completion: nil)
                } else {
                    delegate?.changeState(to: .orderFlowWaiting, completion: nil)
                }
            }
            
            if (transactionIntent && SessionManager.currentIntentString?.lowercased() != "connect" && SessionManager.shouldCheckMarketStatus()) {
                SessionManager.currentlySelectedBroker = Broker(name: userBrokerConfig.broker)
                SCGateway.shared.checkMarketStatus(completion: { [weak self] (result) in
                    switch result {
                        case .success(let isOpen):
                            
                            if !isOpen {
                                if self?.userBrokerConfig != nil {
                                    self?.updateBroker(brokerConfig: (self?.userBrokerConfig!)!)
                                }
                                self?.handleError(SessionManager.currentTransactionIdStatus, .marketClosed)
                                
                                return
                            } else {
                                self?.initiateTransactionWebView(transactionId: self?.transactionId ?? "", isNativeLogin: nil)
                            }
                            
                        case .failure(let error):
                            print(error)
                            self?.handleError(SessionManager.currentTransactionIdStatus, TransactionError.apiError)
                    }
                })
            } else {
                initiateTransactionWebView(transactionId: transactionId, isNativeLogin: nil)
            }
            
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.delegate?.showBrokerSelector()
            }
        }
    }
    
    func initiateTransactionWebView(transactionId: String, isNativeLogin: Bool?) {
        
        SCGateway.shared.getBrokerTransactionUrl(
            transactionId: transactionId,
            brokerConfig: userBrokerConfig!,
            isleprechaunActivated: leprechaunActivated,
            isNativeLoginEnabled: isNativeLogin ?? isNativeLoginEnabled(self.userBrokerConfig)) { [weak self] (result) in
                
                switch result {
                    case .success(let url):
                        DispatchQueue.main.async {
                            self?.openGateway(url: url)
                        }
                        
                    case .failure(let error):
                        print(error)
                }
            }
        
    }
    
    func updateBroker(brokerConfig: BrokerConfig) {
        SCGateway.shared.updateBroker(tranxId: self.transactionId , broker: brokerConfig.broker, isLeprechaun: leprechaunActivated)
    }
    
    //MARK: Launch Transaction URL
    internal func openGateway(url: URL?) {
        
        SCGateway.shared.registerMixpanelEvent(
            eventName: MixpanelConstants.EVENT_BROKER_PLATFORM_OPENED,
            additionalProperties: [
                "transactionId": SessionManager.currentTransactionId ?? "NA",
                "intent": SessionManager.currentIntentString ?? "NA",
                "transactionStatus": SessionManager.currentTransactionIdStatus?.status ?? "NA",
                "brokerURL": url?.absoluteURL ?? "NA"
            ])
        
        if #available(iOS 13.0, *) {
            
            webAuthProvider = nil
            
            gatewayAuthProvider = GatewayAuthenticationProvider(
                url: url!,
                callbackURLScheme: Constants.callbackUrlScheme,
                presentationContextProvider: webPresentationContextProvider as? ASWebAuthenticationPresentationContextProviding,
                completionHandler: { [weak self] (url, err) in
                    
                    guard let self = self else { return }
                    
                    self.webAuthCompletionUrl = url
                    self.webAuthCompletionError = err
                    
                    self.processBpRedirectionFromWebAuthentication(url, err)
                })
            
            if let gatewayAuthProvider = self.gatewayAuthProvider as? GatewayAuthenticationProvider, gatewayAuthProvider.start() {
                print("-------------------- Gateway transaction session started --------------------------")
            }
            
        } else {
            
            webAuthProvider = WebAuthenticationProvider(
                url: url!,
                callbackURLScheme: Constants.callbackUrlScheme,
                completionHandler: { [weak self] (url, err) in
                    
                    guard let self = self else { return }
                    
                    self.webAuthCompletionUrl = url
                    self.webAuthCompletionError = err
                    
                    self.processBpRedirectionFromWebAuthentication(url, err)
                })
            
            if webAuthProvider.start() {
                print("-------------------- Gateway transaction session started --------------------------")
            }
        }
    }
    
    private func processBpRedirectionFromWebAuthentication(_ bpDeeplinkURL: URL?, _ err: Error?) {
        
        if let error = err {
            self.webAuthCompletion(callbackURL: bpDeeplinkURL, err: error)
        } else {
            
            guard let callbackURL = bpDeeplinkURL else {
                return
            }
            
            print("Broker Platform callback URL from web: \(String(describing: bpDeeplinkURL))")
            
            SCGateway.shared.registerMixpanelEvent(
                eventName: MixpanelConstants.EVENT_SDK_INTENT_RETURNED,
                additionalProperties: [
                    "transactionId": SessionManager.currentTransactionId ?? "NA",
                    "transactionStatus": SessionManager.currentTransactionIdStatus?.status ?? "NA",
                    "intent": SessionManager.currentIntentString ?? "NA",
                    "BP Intent": callbackURL.absoluteString
                ])
            
            if self.isNativeLoginEnabled(self.userBrokerConfig) {
                launchNativeBrokerApp()
            } else {
                self.webAuthCompletion(callbackURL: callbackURL, err: err)
            }
        }
        
    }
    
    internal func webAuthCompletion(callbackURL: URL?, err: Error?) {
        
        if isLogout {
            
            self.handleBpLogoutRedirection()
            
        } else if showOrders {
            
            //            SessionManager.showOrders = false
            self.coordinatorDelegate?.nonTransactionalIntentCompleted(success: true, error: nil)
            
        } else {
            webAuthProvider = nil
            
            fetchAndHandleTransactionStatus(
                completionStatus: extractTxnStatusFromBpResponse(callbackURL?.query).status,
                errorReason: extractTxnStatusFromBpResponse(callbackURL?.query).error
            )
        }
        
        
        //Destroy web auth instance
        if #available(iOS 13, *) {
            gatewayAuthProvider = nil
        } else {
            self.webAuthProvider = nil
        }
    }
    
    /// Extracts the values from the query parameters returned by Broker Platform callback URL
    /// - Parameter query1: The query parameter string of the callbackURL
    /// - Returns: TransactionCallbackStatus for success and TransactionError for error
    internal func extractTxnStatusFromBpResponse(_ queryParam: String?) -> (status: TransactionCallbackStatus?, error:TransactionError?) {
        
        guard let query = queryParam else {
            return (TransactionCallbackStatus(rawValue: ""), TransactionError.init(rawValue: -1, message: ""))
        }
        
        let queryComponents = query.components(separatedBy: "&")
        var transactionStatus: String = ""
        var errorReason: String =  ""
        var errorCode: Int = -1
        
        queryComponents.forEach { (component) in
            if component.contains("status") {
                transactionStatus = component.components(separatedBy: "=").last ?? ""
            }
            
            if component.contains("error") {
                errorReason = component.components(separatedBy: "=").last ?? ""
            }
            
            if component.contains("code") {
                errorCode = Int(component.components(separatedBy: "=").last ?? "-1") ?? -1
            }
            
        }
        
        return (TransactionCallbackStatus(rawValue: transactionStatus),TransactionError.init(rawValue: errorCode, message: errorReason))
    }
    
    //MARK: Fetch transaction status
    /// Fetches the transaction status and forwards the handling of success and error cases
    /// - Parameters:
    ///   - completionStatus: the completion status (if any) coming from broker platform
    ///   - errorReason: the error status (if any) coming from broker platform
    private func fetchAndHandleTransactionStatus(completionStatus: TransactionCallbackStatus?,errorReason: TransactionError?) {
        
        SCGateway.shared.fetchTransactionStatus(transactionId: transactionId) { [weak self] (result) in
            switch result {
                case .success(let response):
                    
                    /// make sure that transaction response is valid else return
                    guard let status = response.data?.transaction?.status, let statusType = TransactionOrderStatus(rawValue: status) else {
                        self?.coordinatorDelegate?.transactionErrored(error: .invalidResponse, successData: nil)
                        return
                    }
                 
                /// If the transaction has already expired
                if response.data?.transaction?.expired ?? false {
                    self?.coordinatorDelegate?.transactionErrored(error: .transactionExpired, successData: response.data?.transaction?.success)
                }
                
                /// if the transaction has been marked as errored by BE
                if self?.isTransactionErrored(trxError: response.data?.transaction?.error) ?? false {
                    self?.handleTransactionError(
                        error: response.data!.transaction!.error!,
                        completionStatus: .errored,
                        errorReason: errorReason,
                        transactionSuccessData: response.data?.transaction?.success
                    )
                } else {
                    /// the transaction is in success or in the process of success state
                    
                    /// Check transaction status value
                    switch statusType {
                    
                        ///Terminal State
                    case .completed, .actionRequired: self?.processSuccessfulTransaction((response.data?.transaction)!)
                        break
                        
                    case .initialized: do {
                        ///Check if FE sent an error via deeplink
                        if (completionStatus == .errored || completionStatus == .cancelled) {
                            self?.handleFECancelledOrErroredStateTransaction(completionStatus, statusType, errorReason, response.data!.transaction!)
                        } else {
                            ///fallback to user_cancelled 1011 error
                            self?.handleError(response.data?.transaction, TransactionError.safariTabClosedInitialised)
                        }
                    }
                    case .used: do {
                        
                        ///Check if FE sent an error via deeplink
                        if (completionStatus == .errored || completionStatus == .cancelled) {
                            self?.handleFECancelledOrErroredStateTransaction(completionStatus, statusType, errorReason, response.data!.transaction!)
                        } else {
                            
                            ///check if the order was requested by the user during a SST/SMT transaction
                            if(response.data?.transaction?.intent == Constants.INTENT_TRANSACTION && response.data?.transaction?.flags?.isOrderRequested == true) {
                                ///Start polling for 30 seconds
                                
                                ///Reached max polling count for order request
                                if self?.pollAttemptedForOrderRequest == Constants.MAX_POLL_ORDER_REQUEST {
                                    self?.handleError(response.data?.transaction, TransactionError.orderPending(data: nil))
                                } else {
                                    ///continue polling
                                    self?.pollForOrderRequest()
                                }
                            } else {
                                ///User dropped off after broker login
                                self?.handleError(response.data?.transaction, TransactionError.safariTabClosedUsed)
                            }
                        }
                        
                    }
                    case .processing: do {
                        switch (response.data?.transaction?.intent ?? "NA") {
                        
                        case Constants.INTENT_TRANSACTION:
                            self?.processSuccessfulTransaction((response.data?.transaction)!)
                            break
                            
                        case Constants.INTENT_HOLDINGS_IMPORT: do {
                            ///show holdings import UI
                            self?.delegate?.changeState(to: .loadHoldings, completion: nil)
                            self?.pollForTransactionStatusHoldings()
                            break
                        }
                        default: do {
                            ///SDK does not have knowledge of this issue => internal_error
                            self?.handleError(nil, .apiError)
                        }
                            
                        }
                    }
                    case .errored: self?.handleError(response.data!.transaction!, TransactionError.apiError)
                        
                    default: do {
                        ///SDK does not have knowledge of this issue => internal_error
                        self?.handleError(nil, .apiError)
                    }
                    }
                }

                case .failure(let error): self?.handleError(nil, error)
            }
        }
    }
    
    //MARK: Handle Transaction Success
    /// Process a transaction in successful or terminal state
    /// - Parameter transactionResponse: The transaction object returned by BE
    private func processSuccessfulTransaction(_ transactionResponse: Transaction) {
        
        ///reset any ongoing polling counters
        resetPollingCounter()
        resetPollingStatusHoldings()
        
        /// Identify the user for Mixpanel
        if let smallcaseAuthId = transactionResponse.authId {
            SCGateway.shared.identifyUser(smallcaseAuthId)
        }
        
        ///update analytics data
        SCGateway.shared.registerMixpanelEvent(eventName: MixpanelConstants.EVENT_BP_RESPONSE_TO_PARTNER,
                                               additionalProperties: [
                                                "transactionId": SessionManager.currentTransactionId ?? "NA",
                                                "transactionStatus" : transactionResponse.status ?? "NA",
                                                "intent": transactionResponse.intent ?? "",
                                                "error_code": 0,
                                                "error_message": "NA"
                                               ])
        
        ///handle individual intent success state
        guard let intentObject = SCGateway.shared.getTransactionType(transactionData: transactionResponse) else { return }
        
        guard let authToken = transactionResponse.success.smallcaseAuthToken else {
            self.handleError(transactionResponse, TransactionError.apiError)
            return
        }
        
        switch intentObject {
            
        case TransactionIntent.connect: do {
            ///Initialise the SDK after broker login
            SCGateway.shared.initializeGateway(sdkToken: authToken) { success, error in
                if success {
                    
                    if SessionManager.copyConfig?.postConnect.show ?? false {
                        self.delegate?.changeState(to: .connected) { [weak self] _ in
                            guard let self = self else { return }
                            self.coordinatorDelegate?.transactionCompleted(transactionId: transactionResponse.transactionId!, transactionData: intentObject, authToken: authToken)
                        }
                    } else {
                        self.coordinatorDelegate?.transactionCompleted(transactionId: transactionResponse.transactionId!, transactionData: intentObject, authToken: authToken)
                    }
                } else {
                    self.handleError(transactionResponse, TransactionError.apiError)
                }
            }
        }
            
        case TransactionIntent.holdingsImport: do {
            ///show holdings import UI
            delegate?.changeState(to: .loadHoldings, completion: nil)
            
            ///share response with host
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 3, execute: {
                self.coordinatorDelegate?.transactionCompleted(
                    transactionId: transactionResponse.transactionId!,
                    transactionData: intentObject,
                    authToken: authToken)
            })
        }
            
        default:
            
            if(transactionResponse.orderConfig?.type != "SECURITIES") {
                var successData = transactionResponse.success
                successData.transactionId = transactionResponse.transactionId
                
                coordinatorDelegate?.transactionCompleted(
                    transactionId: transactionId,
                    transactionData: .transaction(
                        smallcaseAuthToken: authToken,
                        transactionData: successData
                    ),
                    authToken: authToken)
            } else {
                
                coordinatorDelegate?.transactionCompleted(
                    transactionId: transactionId,
                    transactionData: intentObject,
                    authToken: authToken)
            }
        }
    }
    
    //MARK: Handle Transaction Error
    func handleTransactionError(
        error: TransactionErrorResponse,
        completionStatus: TransactionCallbackStatus,
        errorReason: TransactionError?,
        transactionSuccessData: Transaction.SuccessData?
    ) {
        
        var trxError = TransactionError(rawValue: error.code ?? errorReason?.rawValue ?? 2000, transactionData: transactionSuccessData)
        
        if trxError == nil {
            if error.code != nil && error.message != nil {
                trxError = .dynamicError(msg: error.message ?? "" , code: error.code ?? -1, data: transactionSuccessData)
            } else {
                trxError = .apiError
            }
        }
        
        if completionStatus == .errored  {
            
            if let errorReason = errorReason {
                trxError = errorReason
            }
            
            resetPollingCounter()
            resetPollingStatusHoldings()
        }
        
        if error.message == "UserMismatch" || error.message == "user_mismatch" {
            
            SCGateway.shared.registerMixpanelEvent(
                eventName: MixpanelConstants.EVENT_BP_RESPONSE_TO_PARTNER,
                additionalProperties: [
                    "transactionId": SessionManager.currentTransactionId ?? "NA",
                    "transactionStatus": transactionSuccessData?.toJSONString() ?? "NA",
                    "intent": SessionManager.currentIntentString ?? "NA",
                    "error_code": error.code ?? "NA",
                    "error_message": error.message ?? "NA"
                ])
            
            delegate?.changeState(to: .loginFailed){ [weak self] _ in
                guard let self = self else { return }
                self.coordinatorDelegate?.transactionErrored(error: .userMismatch, successData: transactionSuccessData)
            }
        } else {
            
            SCGateway.shared.registerMixpanelEvent(
                eventName: MixpanelConstants.EVENT_BP_RESPONSE_TO_PARTNER,
                additionalProperties: [
                    "transactionId": SessionManager.currentTransactionId ?? "NA",
                    "transactionStatus": transactionSuccessData?.toJSONString() ?? "NA",
                    "intent": SessionManager.currentIntentString ?? "NA",
                    "error_code": trxError?.rawValue ?? "NA",
                    "error_message": trxError?.message ?? "NA"
                ])
            
            coordinatorDelegate?.transactionErrored(error: trxError!, successData: transactionSuccessData)
        }
        
    }
    
    private func handleError(_ transactionResponse: Transaction?, _ transactionError: TransactionError) {
        SCGateway.shared.registerMixpanelEvent(
            eventName: MixpanelConstants.EVENT_BP_RESPONSE_TO_PARTNER,
            additionalProperties: [
                "transactionStatus": transactionResponse?.status ?? "NA",
                "transactionId": transactionResponse?.transactionId ?? SessionManager.currentTransactionId ?? "NA",
                "intent": transactionResponse?.intent ?? SessionManager.currentIntentString ?? "NA",
                "error_code": transactionError.rawValue,
                "error_message": transactionError.message
            ])
        
        self.markTransactionErrored(transactionError)
        
        self.coordinatorDelegate?.transactionErrored(error: transactionError, successData: transactionResponse?.success)
    }
    
    internal func markTransactionErrored(_ error: TransactionError) {
        SCGateway.shared.markTransactionErrored(transactionId: transactionId, error: error) { (result) in
            print("MARK TRANSACTION ERRORED: \(result)")
        }
    }
    
    func isTransactionErrored(trxError: TransactionErrorResponse?) -> Bool {
        guard let trxError = trxError else { return false }
        return trxError.value
    }
    
    private func handleFECancelledOrErroredStateTransaction(
        _ completionStatus: TransactionCallbackStatus?,
        _ transactionStatus: TransactionOrderStatus?,
        _ errorReason: TransactionError?,
        _ transaction: Transaction
    ) {
        
        guard let intentObject = SCGateway.shared.getTransactionType(transactionData: transaction)
        else { return }
        
        var transactionError = completionStatus == .errored ? TransactionError.apiError : transactionStatus == TransactionOrderStatus.initialized ? .safariTabClosedInitialised :  .safariTabClosedUsed
        
        if let errorReason = errorReason {
            transactionError = errorReason
        }
        
        if case TransactionIntent.connect = intentObject {
            if errorReason?.rawValue == TransactionError.userMismatch.rawValue {
                //Broker mismatch
                delegate?.changeState(to: .loginFailed, completion: nil)
            }
        }
        
        handleError(transaction, transactionError)
    }
    
    //MARK: Polling
    private func pollForOrderRequest() {
        if pollAttemptedForOrderRequest < Constants.MAX_POLL_ORDER_REQUEST {
            pollAttemptedForOrderRequest += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.POLL_DELAY_INTERVAL) { [weak self] in
                ///Since completionStatus and ErrorReason would have been checked by now => pass nil
                ///Fetch the transaction status and respond accordingly
                self?.fetchAndHandleTransactionStatus(completionStatus: nil, errorReason: nil)
            }
        }
    }
    
    func pollForTransactionStatus() {
        
        if !pollingTransactionStatus && pollingRequestsRemaining == Constants.MAX_POLL_COUNT {
            
            pollingTransactionStatus = true
        }
        
        if pollingRequestsRemaining == 0 {
            resetPollingCounter()
            fetchAndHandleTransactionStatus(completionStatus: .cancelled, errorReason: nil)
        }
        
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.POLL_DELAY_INTERVAL) { [weak self] in
                self?.pollingRequestsRemaining -= 1
                self?.fetchAndHandleTransactionStatus(completionStatus: .cancelled, errorReason: nil)
            }
        }
    }
    
    func pollForTransactionStatusHoldings() {
        
        if !pollingTransactionStatus && pollingReqestsRemainingHoldings == Constants.MAX_POLL_HOLDINGS {
            
            pollingTransactionStatus = true
        }
        
        if pollingReqestsRemainingHoldings == 0 {
            resetPollingStatusHoldings()
            self.handleError(nil, .timedOutError)
        }
        
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.POLL_DELAY_INTERVAL) { [weak self] in
                self?.pollingReqestsRemainingHoldings -= 1
                self?.fetchAndHandleTransactionStatus(completionStatus: .cancelled, errorReason: nil)
            }
        }
    }
    
    func resetPollingCounter() {
        if pollingTransactionStatus {
            pollingTransactionStatus = false
            pollingRequestsRemaining = Constants.MAX_POLL_COUNT
        }
        
        pollAttemptedForOrderRequest = 0
    }
    
    func resetPollingStatusHoldings() {
        if pollingTransactionStatus {
            pollingTransactionStatus = false
            pollingReqestsRemainingHoldings = Constants.MAX_POLL_HOLDINGS
        }
    }
}
