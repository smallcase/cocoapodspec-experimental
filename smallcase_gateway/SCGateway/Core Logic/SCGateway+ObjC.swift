//
//  SCGateway+ObjC.swift
//  SCGateway
//
//  Created by Ankit Deshmukh on 26/05/22.
//  Copyright © 2022 smallcase. All rights reserved.
//

import Foundation

extension SCGateway {
    
    //MARK: Trigger Transaction
    
    ///Only for objective C compatibility
    @objc public func triggerTransactionFlow(transactionId: String, presentingController: UIViewController, completion: @escaping(Any?, ObjcTransactionError?) -> Void) {
        do {
            try triggerTransactionFlow(transactionId: transactionId, presentingController: presentingController) { result in
                
                switch(result) {
                case .success(let transactionResponse) :
                    switch transactionResponse {
                     
                        case let .subscription(response):
                            completion(_ObjCTransactionIntentSubscription(response), nil)
                    
                        case let .transaction(authToken, transactionData):
                            completion(_ObjcTransactionIntentTransaction(authToken, transactionData), nil)
                     
                        case let .connect(response):
                            completion(_ObjCTransactionIntentConnect(response), nil)
               
                        case let .holdingsImport(authToken, broker, status, transactionId, signup):
                            completion(_ObjcTransactionIntentHoldingsImport(authToken, status, broker, transactionId, signup), nil)
                     
                        case let .authoriseHoldings(smallcaseAuthToken, status, transactionId, signup):
                            completion(_ObjcTransactionIntentAuthoriseHoldings(smallcaseAuthToken, status,transactionId, signup), nil)
                    
                        case let .fetchFunds(smallcaseAuthToken, fund, transactionId, signup):
                            completion(_ObjcTransactionIntentFetchFunds(smallcaseAuthToken, fund, transactionId, signup), nil)
                     
                        case let .sipSetup(smallcaseAuthToken, sipAction, transactionId, signup):
                            completion(_ObjcTransactionIntentSipSetup(smallcaseAuthToken, sipAction, transactionId, signup), nil)
                            
                        case let .cancelAMO(response):
                            completion(_ObjCTransactionIntentCancelAmo(response), nil)
                    case let .onboarding(response):
                        completion(_ObjCTransactionIntentOnboarding(response), nil)
                    default: return
                    }
                case .failure(let error) :
                    completion(nil, ObjcTransactionError(error: error))
                }
            }
        } catch let err {
            guard let scGatewayError = err as? SCGatewayError else {
                completion(nil, ObjcTransactionError(error: .apiError))
                return
            }
            completion(nil, ObjcTransactionError(error: scGatewayError))
        }
    }
    
    @objc public func triggerTransactionFlow(transactionId: String, presentingController: UIViewController,utmParams:Dictionary<String,String>?,brokerConfig:[String]?, completion: @escaping(Any?, ObjcTransactionError?) -> Void){
        
        if let scBrokerConfig = brokerConfig {
            SessionManager.brokerConfigType = scBrokerConfig.isEmpty ? .defaultConfig : .custom(brokerConfig!)
        } else {
            SessionManager.brokerConfigType = .defaultConfig
        }
        
        triggerTransactionFlow(transactionId: transactionId, presentingController: presentingController,utmParams: utmParams, completion: completion)
    }
    
    @objc public func triggerTransactionFlow(transactionId: String, presentingController: UIViewController,utmParams:Dictionary<String,String>?, completion: @escaping(Any?, ObjcTransactionError?) -> Void){
        SessionManager.utmParams = utmParams
        triggerTransactionFlow(transactionId: transactionId, presentingController: presentingController, completion: completion)
    }
    
    // For objc compatibility
    @available(*, deprecated, message: "Will be removed soon. Use triggerTransactionFlow instead.")
    @objc public func triggerMfTransaction(presentingController: UIViewController, transactionId: String, completion: @escaping(Any?, ObjcTransactionError?) -> Void) {
        if SessionManager.gatewayName == nil && SessionManager.sdkToken == nil {
            completion(nil, ObjcTransactionError(error: .uninitialized))
        } else {
            
            print("------------------- Launching MF Holdings Import ------------------------")
            
            fetchTransactionStatusFirst(transactionId: transactionId) { result in
                switch result {
                case .success(let response) :
                    guard let txn = response.data?.transaction else {
                        completion(nil, ObjcTransactionError(error: .invalidTransactionId))
                        return
                    }
                    let intent = self.getTransactionType(transactionData: txn)
                    switch intent {
                    case .mfHoldingsImport(_) :
                        DispatchQueue.main.async { [weak self] in
                            
                            self?.mfCoordinator = MFCoordinator(presentingViewController: presentingController,transactionId: transactionId, completion: completion)
                            self?.mfCoordinator.start()
                        }
                    default: completion(nil, ObjcTransactionError(error: .invalidTransactionId))
                    }
                case .failure(let error):
                    completion(nil, ObjcTransactionError(error: error))
                }
            }
        }
        
        updateDeviceType(tranxId: transactionId, device: "ios")
    }
    
    //Only for objective C compatibility
    @objc private func openBrokerSelect(_ presentingController: UIViewController,_ transactionId: String,_ transactionIntent:Bool, completion: @escaping (Any?, ObjcTransactionError?) -> Void ) {
        
        DispatchQueue.main.async { [weak self] in
            
            self?.brokerSelectCoordinator = BrokerSelectCoordinator(presentingViewController: presentingController, transactionId: transactionId, transactionIntent: transactionIntent, completion: completion)
            
            self?.brokerSelectCoordinator.start()
        }
    }
    
    //MARK: - Lead Gen
    
    @objc public func triggerLeadGen(presentingController: UIViewController,params:Dictionary<String,String>?) {
        
        if SessionManager.gatewayName != nil && SessionManager.sdkToken != nil {
            
            let leadGenController = LeadGenController(params: params, showLoader: true, leadGenUtmParams: nil, isRetargeting: nil)
            leadGenController.view.backgroundColor = UIColor.init(white: 0, alpha: 0.8)
            leadGenController.modalPresentationStyle = .overFullScreen
            presentingController.present(leadGenController, animated: false, completion: nil)
            
        }
    }
    
    @objc public func triggerLeadGen(presentingController: UIViewController,params:Dictionary<String,String>?, completion: @escaping(String?) -> Void){
        
        if SessionManager.gatewayName != nil && SessionManager.sdkToken != nil {
            
            let leadGenController = LeadGenController(params: params, showLoader: true, leadGenUtmParams: nil, isRetargeting: nil, leadGenCompletion: completion)
            leadGenController.view.backgroundColor = UIColor.init(white: 0, alpha: 0.8)
            leadGenController.modalPresentationStyle = .overFullScreen
            presentingController.present(leadGenController, animated: false, completion: nil)
            
        }
    }
    
    @objc public func triggerLeadGen(presentingController: UIViewController,params:Dictionary<String,String>?, utmParams: Dictionary<String, String>?){
        
        if SessionManager.gatewayName != nil && SessionManager.sdkToken != nil {
            
            SessionManager.leadGenUtmParams = utmParams
            SessionManager.isRetargeting = false
            
            let leadGenController = LeadGenController(params: params, showLoader: true, leadGenUtmParams: SessionManager.leadGenUtmParams, isRetargeting: SessionManager.isRetargeting)
            leadGenController.view.backgroundColor = UIColor.init(white: 0, alpha: 0.8)
            leadGenController.modalPresentationStyle = .overFullScreen
            presentingController.present(leadGenController, animated: false, completion: nil)
            
        }
    }
    
    @objc public func triggerLeadGen(presentingController: UIViewController,params:Dictionary<String,String>?, utmParams: Dictionary<String, String>?, retargeting: Bool){
        
        if SessionManager.gatewayName != nil && SessionManager.sdkToken != nil {
            
            SessionManager.leadGenUtmParams = utmParams
            SessionManager.isRetargeting = retargeting
            
            let leadGenController = LeadGenController(params: params, showLoader: true, leadGenUtmParams: SessionManager.leadGenUtmParams, isRetargeting: SessionManager.isRetargeting)
            leadGenController.view.backgroundColor = UIColor.init(white: 0, alpha: 0.8)
            leadGenController.modalPresentationStyle = .overFullScreen
            presentingController.present(leadGenController, animated: false, completion: nil)
            
        }
    }
    
    @objc public func triggerLeadGen(
        presentingController: UIViewController,
        params:Dictionary<String,String>?,
        utmParams: Dictionary<String, String>?,
        retargeting: Bool,
        showLoginCta: Bool,
        completion: @escaping(String?) -> Void
    ) {
        
        if SessionManager.gatewayName != nil && SessionManager.sdkToken != nil {
            
            SessionManager.leadGenUtmParams = utmParams
            SessionManager.isRetargeting = retargeting
            
            let leadGenController = LeadGenController(
                params: params,
                showLoader: true,
                leadGenUtmParams: SessionManager.leadGenUtmParams,
                isRetargeting: SessionManager.isRetargeting,
                showLoginCta: showLoginCta,
                leadGenCompletion: completion
            )
            
            leadGenController.view.backgroundColor = UIColor.init(white: 0, alpha: 0.8)
            leadGenController.modalPresentationStyle = .overFullScreen
            presentingController.present(leadGenController, animated: false, completion: nil)
            
        }
    }
}
