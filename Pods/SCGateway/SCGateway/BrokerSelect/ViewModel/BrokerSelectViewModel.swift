//
//  BrokerSelectViewModel.swift
//  SCGateway
//
//  Created by Shivani on 06/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import AuthenticationServices
import UIKit


protocol BrokerSelectViewModelProtocol: HeaderFooterTapDelegate {
    
    @available(iOS 13.0, *)
    var webPresentationContextProvider: ASWebAuthenticationPresentationContextProviding? {get set }
    
    var model: BrokerSelectModelProtocol? { get set}
    
    var coordinatorDelegate: BrokerSelectCoordinatorVMDelegate? { get set }
    
    var delegate: BrokerSelectVMDelegate? { get set }
    
    var transactionId: String { get set }
    
    var userBrokerConfig: BrokerConfig? { get set }
    
    var numberOfItems: Int { get }
    
    func getBrokerConfig()
    
    func config(at index: Int) -> BrokerConfig?
    
    func getConnectedBrokerConfig (brokersConfigArray: [BrokerConfig]) -> BrokerConfig?
    
    init(model: BrokerSelectModelProtocol, transactionId: String)
    
}

protocol BrokerSelectVMDelegate: class {
    func showBrokerSelector()
    func changeState(to viewState: ViewState)
    func leprechaunStateChanged()
}

protocol BrokerSelectCoordinatorVMDelegate: class {
    
    func dismissBrokerSelect()
    func transactionCompleted(transactionId: String, transactionData: TransactionIntent, authToken: String)
    func transactionErrored(transactionId: String, error: TransactionError)
}


class BrokerSelectViewModel: NSObject, BrokerSelectViewModelProtocol {
    
    @available(iOS 13.0, *)
    lazy var webPresentationContextProvider: ASWebAuthenticationPresentationContextProviding? = nil
    
    private enum Constants {
        
        /// Max number of times the request has to be polled
        static let MAX_POLL_COUNT = 3
        
        // number of seconds delay between every poll request
        static let POLL_DELAY_INTERVAL = 2.0
        
        static let leprechaunPostFix = "-leprechaun"
        static let callbackUrlScheme = "scgateway"
        
    }
    
    // Transaction Related
    internal var transactionId: String
    
    internal var model: BrokerSelectModelProtocol?
    
    internal  weak var delegate: BrokerSelectVMDelegate?
    
    internal weak var coordinatorDelegate: BrokerSelectCoordinatorVMDelegate?
    
    ///Wrapper for web auth session
    private var webAuthProvider: WebAuthenticationProvider!
    
    /// Gets set Whenever user selects a config (from broker choser
    internal var userBrokerConfig: BrokerConfig? {
        didSet {
            triggerFlowBasedOnSelectedBrokerConfig()
        }
    }
    
    // Broker Config  for all brokers
    private var config: [BrokerConfig]? {
        didSet{
            guard let config = config else { return }
            userBrokerConfig = getConnectedBrokerConfig(brokersConfigArray: config)
        }
    }
    
    private var leprechaunActivated: Bool {
        get {
            return Config.isLeprechaunActive
            
        }
        set {
            Config.isLeprechaunActive = newValue
            delegate?.leprechaunStateChanged()
            
        }
    }
    
    // For Polling transaction status (in case of pending transaction processing )
    /// Is true when polling ongoing
    private var pollingTransactionStatus = false
    
    // number of times the request has to be polled
    private var pollingRequestsRemaining = Constants.MAX_POLL_COUNT
    
    // MARK: - Table View Data source
    internal  var numberOfItems: Int {
        return config?.count ?? 0
    }
    
    //MARK:- CONFIG
    
    internal func config(at index: Int) -> BrokerConfig? {
        return config?[index]
    }
    
    internal func getBrokerConfig() {
        
        self.model?.getBrokerData(completion: { [weak self] (result) in
            switch result {
            case .success(let config):
                self?.config = config
                Config.brokerConfig = config
                
            case .failure(let error):
                print("BROKER CONFIG ERROR: \(error)")
            }
        })
    }
    
    //Checks and returns a valid broker if already selected
    func getConnectedBrokerConfig (brokersConfigArray: [BrokerConfig]) -> BrokerConfig? {
        
        var absoluteBrokerName = Config.broker?.name
        if let broker = Config.broker {
            if broker.name?.contains(Constants.leprechaunPostFix) ?? false {
                leprechaunActivated = true
                absoluteBrokerName = broker.name?.replacingOccurrences(of: Constants.leprechaunPostFix, with: "")
            }
        }
        
        let matchedBrokerConfigList =  brokersConfigArray.filter({ (item) -> Bool in
            item.broker == absoluteBrokerName
        })
        
        if matchedBrokerConfigList.isEmpty  { return nil }
        return matchedBrokerConfigList[0]
        
    }
    
    /// Checks if the user has any broker sets
    private func triggerFlowBasedOnSelectedBrokerConfig() {
        
        // removes leprechaun substring if set
        if userBrokerConfig != nil {
            initiateGatewayWebView(transactionId: transactionId)
        }
        else {
            delegate?.showBrokerSelector()
        }
    }
    
    private func initiateGatewayWebView(transactionId: String) {
        
        SCGateway.shared.getBrokerTransactionUrl(transactionId: transactionId, brokerConfig: userBrokerConfig!, isleprechaunActivated: leprechaunActivated) { [weak self] (result) in
            switch result {
            case .success(let url):
                self?.openGateway(url: url)
                
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    private func getTransactionCompletionStatus(_ query: String) -> (status: TransactionCallbackStatus?, reason: TransactionErrorReason?) {
        let queryComponents = query.components(separatedBy: "&")
        var transactionStatus: String? = nil
        var errorReason: String? =  nil
        
        queryComponents.forEach { (component) in
            if component.contains("status") {
                transactionStatus = component.components(separatedBy: "=").last ?? nil
            }
            
            if component.contains("reason") {
                errorReason = component.components(separatedBy: "=").last ?? nil
            }
        }
        
        
        return (TransactionCallbackStatus(rawValue: transactionStatus ?? ""), TransactionErrorReason(rawValue: errorReason ?? ""))
    }
    
    
    /// WHen user selects a broker, initiates web session
    private func openGateway(url: URL?){
        if #available(iOS 13, *) {
            webAuthProvider = WebAuthenticationProvider(url:  url!, callbackURLScheme: Constants.callbackUrlScheme, presentationContextProvider: webPresentationContextProvider, completionHandler: { [weak self ] (url, err) in
                print("GOT CALLBACK")
                
                self?.webAuthCompletion(url: url, err: err)
            })
        }
        else {
            webAuthProvider = WebAuthenticationProvider(
                url: url!,
                callbackURLScheme: Constants.callbackUrlScheme,
                completionHandler: {
                    [weak self ] (url, err) in
                    print("GOT CALLBACK")
                    
                    self?.webAuthCompletion(url: url, err: err)
                    
            })
        }
        
        if  webAuthProvider.start() {
            print("Web session started")
        }
    }
    
    private func webAuthCompletion(url: URL?, err: Error?) {
        if url != nil {
            guard let query = url!.query,
                let completionStatus = getTransactionCompletionStatus(query).status
                else { return }
            
            updateTransactionStatus(completionStatus: completionStatus, errorReason: getTransactionCompletionStatus(query).reason)
        }
        
        if (err != nil) {
            webAuthProvider = nil
            //TODO: Check Error Case
            var responseError: TransactionError = .apiError
            if ((err as? WebAuthenticationProvider.Error) != nil) {
                responseError = .userCancelled
            }
            
            coordinatorDelegate?.transactionErrored(transactionId: self.transactionId, error: responseError)
            
            markTransactionErrored(responseError)
            coordinatorDelegate?.dismissBrokerSelect()
        }
        
        //Destroy web auth instance
        webAuthProvider = nil
    }
    
    private  func markTransactionErrored(_ error: TransactionError) {
        
        SCGateway.shared.markTransactionErrored(transactionId: transactionId, error: error) { (result) in
            print("MARK TRAANSACTION ERRORED: \(result)")
        }
    }
    
    /// After auth session completes, fetches transaction status
    private func updateTransactionStatus(completionStatus: TransactionCallbackStatus, errorReason: TransactionErrorReason?) {
        
        SCGateway.shared.fetchTransactionStatus(transactionId: transactionId) { [weak self] (result) in
            switch result {
            case .success(let response):
                guard
                    let status = response.data?.transaction?.status,
                    let statusType = TransactionOrderStatus(rawValue: status) else
                {
                    self?.coordinatorDelegate?.dismissBrokerSelect()
                    self?.coordinatorDelegate?.transactionErrored(transactionId: self!.transactionId, error: .invalidResponse)
                    return
                    
                }
                
                if self?.isTransactionErrored(trxError: response.data?.transaction?.error) ?? true {
                    
                    self?.handleTransactionError(error: response.data!.transaction!.error! , completionStatus: completionStatus, errorReason: errorReason)
                    
                }
                else {
                    self?.handleTransactionSuccess(transactionId: self?.transactionId ?? "", transaction: response.data!.transaction!, transactionStatus: statusType, errorReason: errorReason, completionStatus: completionStatus)
                }
                
            case .failure(_):
                self?.coordinatorDelegate?.dismissBrokerSelect()
                self?.coordinatorDelegate?.transactionErrored(transactionId: self!.transactionId, error: .invalidTransactionId)
                
            }
        }
    }
    
    func isTransactionErrored(trxError: TransactionErrorResponse?) -> Bool {
        guard let trxError = trxError else { return false }
        return trxError.value
    }
    
    func handleTransactionError(error: TransactionErrorResponse, completionStatus: TransactionCallbackStatus, errorReason: TransactionErrorReason?) {
        
        var trxError = TransactionError(rawValue: error.code!)
        if trxError == nil {
            trxError = .internalError
        }
        
        if completionStatus == .errored  {
            //MAp Errors
            if let reason = errorReason {
                trxError = getTransactionError(for: reason)
            }
            
            resetPollingCounter()
            //TODO: - Show Errored UI Screen
        }
        
        if trxError! == TransactionError.userMismatch {
            delegate?.changeState(to: .loginFailed)
        }
        else {
            coordinatorDelegate?.dismissBrokerSelect()
        }
        
        coordinatorDelegate?.transactionErrored(transactionId: self.transactionId, error: trxError!)
        
    }
    
    private func handleTransactionSuccess(transactionId: String, transaction: Transaction, transactionStatus: TransactionOrderStatus, errorReason: TransactionErrorReason?, completionStatus: TransactionCallbackStatus) {
        guard
            let intentObject = SCGateway.shared.getTransactionType(transactionData: transaction)
            else { return }
        let authToken = transaction.success.smallcaseAuthToken
        switch transactionStatus {
        case .completed:
            
            resetPollingCounter()
            
            if case TransactionIntent.connect = intentObject {
                if SCGateway.shared.delegate?.shouldDisplayConnectCompletion?() ?? true {
                    delegate?.changeState(to: .connected)
                }
            }
            else {
                coordinatorDelegate?.dismissBrokerSelect()
            }
            coordinatorDelegate?.transactionCompleted(transactionId: transactionId, transactionData: intentObject, authToken: authToken!)
            
            
        case .initialized, .used:
            
            switch completionStatus {
                
                
            case .errored, .cancelled:
                
                var transactionError = completionStatus == .errored ? TransactionError.apiError : .userCancelled
                if let errorReason = errorReason {
                    transactionError = getTransactionError(for: errorReason)
                }
                //Mark Errored
                markTransactionErrored(transactionError)
                
                if case TransactionIntent.connect = intentObject {
                    //Broker mismatch
                    delegate?.changeState(to: .loginFailed)
                }
                else {
                    coordinatorDelegate?.dismissBrokerSelect()
                }
                coordinatorDelegate?.transactionErrored(transactionId: transactionId, error: transactionError)
                
            //TODO:- Handle Failiure UI Screens
            default:
                //Would never happen
                return
            }
            
        //Only for non-connect cases
        case .processing:
            
            if case TransactionIntent.holdingsImport = intentObject {
                guard let authId = transaction.authId else { return }
                coordinatorDelegate?.dismissBrokerSelect()
                coordinatorDelegate?.transactionCompleted(transactionId: transactionId, transactionData: intentObject, authToken: authId)
                return
            }
            else {
                
                switch completionStatus {
                case .cancelled :
                    pollForTransactionStatus()
                    
                //TODO:- Trigger Polling
                case .pending:
                    delegate?.changeState(to: .orderInQueue)
                    coordinatorDelegate?.transactionErrored(transactionId: transactionId, error: .userAbandoned)
                    
                default :
                    return
                    
                }
            }
            
        default:
            return
            
        }
    }
    
    private func getTransactionError(for errorReason: TransactionErrorReason) -> TransactionError {
        
        var trxError: TransactionError
        switch errorReason {
        case .consentDenied:
            trxError = .consentDenied
        case .holdingmportError:
            trxError = .holdingsImportError
        case .insufficientHoldings:
            trxError = .insufficientHoldings
        case .marketClosed:
            trxError = .marketClosed
        case .transactionExpired:
            trxError = .marketClosed
        case .apiError:
            trxError = .internalError
        case .userMismatch:
            trxError = .userMismatch
        }
        return trxError
    }
 
    //MARK:- Polling -
    
    func pollForTransactionStatus() {
        
        if !pollingTransactionStatus && pollingRequestsRemaining == Constants.MAX_POLL_COUNT {
            
            pollingTransactionStatus = true
        }
        
        if pollingRequestsRemaining == 0 {
            
            resetPollingCounter()
            
            //TODO: - Trigger Completion
            delegate?.changeState(to: .orderInQueue)
            coordinatorDelegate?.transactionErrored(transactionId: transactionId, error: .userAbandoned)
        }
            
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.POLL_DELAY_INTERVAL) { [weak self] in
                self?.pollingRequestsRemaining -= 1
                self?.updateTransactionStatus(completionStatus: .cancelled, errorReason: nil)
            }
        }
    }
    
    
    func resetPollingCounter() {
        if pollingTransactionStatus {
            pollingTransactionStatus = false
            pollingRequestsRemaining = Constants.MAX_POLL_COUNT
        }
    }
    
    // MARK: - Initialization
    
    required init(model: BrokerSelectModelProtocol, transactionId: String) {
        self.model = model
        self.transactionId = transactionId
    }
    
}

//MARK:- Delegate
extension BrokerSelectViewModel: HeaderFooterTapDelegate {
    
    func didTapSignup() {
        
        guard let url = URL(string: "https://www.smallcase.com/signup") else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func shouldChangeLeprechaunStatus() {
        leprechaunActivated = !leprechaunActivated
    }
    
    func dismissPopup() {
        coordinatorDelegate?.dismissBrokerSelect()
    }
    
}


