//
//  BrokerSelectViewModel+NonTransactional.swift
//  SCGateway
//
//  Created by Ankit Deshmukh on 07/06/22.
//  Copyright © 2022 smallcase. All rights reserved.
//

import Foundation

/**
 * Contains code for Non Transactional Intents such as show orders, logout etc.
 */
extension BrokerSelectViewModel {
    
    //MARK: Logout
    internal func initiateLogoutWebView(){
        SCGateway.shared.getLogoutUrl(brokerConfig: userBrokerConfig!, isleprechaunActivated: leprechaunActivated) { [weak self] (result) in
            switch result {
                
                case .success(let url):
                    DispatchQueue.main.async {
                        self?.openGateway(url: url)
                    }
                
                case .failure(let error):
                    self?.coordinatorDelegate?.logoutFailed(error: error)
            }
        }
    }
    
    internal func handleBpLogoutRedirection() {
        guard let callbackURL = self.webAuthCompletionUrl else {
            self.coordinatorDelegate?.logoutFailed(error: TransactionError.apiError)
            return
        }
        let result = extractTxnStatusFromBpResponse(callbackURL.query)
        if result.status != nil {
            switch result.status {
            case .completed:
                self.coordinatorDelegate?.logoutSuccessful()
            default:
                self.coordinatorDelegate?.logoutFailed(error: TransactionError.apiError)
            }
        } else {
            self.coordinatorDelegate?.logoutFailed(error: TransactionError.apiError)
        }
    }
    
    
    //MARK: Show Orders
    internal func initiateShowOrdersWebView() {
        
        if userBrokerConfig != nil {
            
            delegate?.changeState(to: .preConnect(brokerConfig: userBrokerConfig!), completion: nil)
            
            SCGateway.shared.getShowOrdersUrl(
                brokerConfig: userBrokerConfig!,
                isleprechaunActivated: leprechaunActivated,
                isNativeLoginEnabled: isNativeLoginEnabled(self.userBrokerConfig)) { [weak self] (result) in
                
                switch result {
                    
                    case .success(let showOrdersUrl):
//                        SessionManager.showOrders = false
                        DispatchQueue.main.async {
                            self?.openGateway(url: showOrdersUrl)
                        }
                        
                    case .failure(let error):
//                        SessionManager.showOrders = false
                        self?.coordinatorDelegate?.nonTransactionalIntentCompleted(success: false, error: error)
                }
            }
            
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.delegate?.showBrokerSelector()
            }
        }
        
    }
    
    //MARK: Lead Gen
    func dismissLeadGen() {
        markTransactionErrored(.signupOtherBroker)
        self.coordinatorDelegate?.transactionErrored(error: .signupOtherBroker, successData: nil)
    }
    
    func dismissLeadGen(_ leadResponse: [String: Any]?) {
        markTransactionErrored(.signupOtherBroker)
        
        let leadResponseDict = [
            "code": TransactionError.signupOtherBroker.rawValue,
            "message": TransactionError.signupOtherBroker.message,
            "data" : leadResponse as Any
        ] as [String : Any]
        
        self.coordinatorDelegate?.transactionErrored(error: .custom(message: leadResponseDict.toJsonString!), successData: nil)
    }
    
    /// Called when a user taps on open an account online cta from the broker chooser
    func didTapSignup() {
        
        let leadGenController = LeadGenController(params: nil, showLoader: true, leadGenUtmParams: nil, isRetargeting: nil)
        leadGenController.delegate = self
        leadGenController.modalPresentationStyle = .overFullScreen
        
        SCGateway.shared.registerMixpanelEvent(
            eventName: MixpanelConstants.EVENT_LAUNCHED_LEAD_GEN_FROM_BROKER_CHOOSER,
            additionalProperties: [
                "transactionStatus": SessionManager.currentTransactionIdStatus?.status ?? "NA",
                "ListOfBrokerPartnersShown": self.getAvailableBrokers() ?? "NA",
                "transactionId": SessionManager.currentTransactionId ?? "NA",
                "intent": SessionManager.currentIntentString ?? "NA",
            ])
        
        coordinatorDelegate?.launchLeadGen(leadGenController, completion: nil)
    }
    
    
}
