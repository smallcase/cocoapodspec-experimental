//
//  BrokerSelectCoordinator.swift
//  SCGateway
//
//  Created by Shivani on 07/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import SafariServices
//import UIKit
//import WebKit

internal class BrokerSelectCoordinator: NSObject, Coordinator, UIViewControllerTransitioningDelegate {
    
    //MARK: Controllers
    var transactionId: String?
    
    var transactionCompletion: ((Result<TransactionIntent, TransactionError>) -> Void)?
    
    var objcTransactionCompletion: ((Any?, ObjcTransactionError?) -> Void)?
    
    var logoutCompletion: ((Bool, Error?) -> Void)?
    
    var genericCompletion: ((Bool, Error?) -> Void)?
    
    var presentingViewController: UIViewController
    
    var safariViewController: SFSafariViewController!
    
    var brokerChooserViewController: BrokerChooserViewController!
    
    var viewModel: BrokerSelectViewModelProtocol!
    
    var transactionIntent:Bool

    init(presentingViewController: UIViewController, transactionId: String,transactionIntent:Bool ,completion: @escaping (Result<TransactionIntent, TransactionError>) -> Void) {

        self.presentingViewController = presentingViewController
        self.transactionId = transactionId
        self.transactionCompletion = completion
        self.objcTransactionCompletion = nil
        self.transactionIntent = transactionIntent
    }
    
    //OBJC COmpatible
    init(presentingViewController: UIViewController, transactionId: String,transactionIntent:Bool ,completion: @escaping (Any?, ObjcTransactionError?) -> Void) {

        self.presentingViewController = presentingViewController
        self.transactionId = transactionId
        self.objcTransactionCompletion = completion
        self.transactionCompletion = nil
        self.transactionIntent = transactionIntent
    }
    
//    init(presentingViewController: UIViewController, completion: @escaping ((Bool, Error?) -> Void)){
//        self.presentingViewController = presentingViewController
//        self.logoutCompletion = completion
//        self.transactionIntent = false
//    }
    
    init(presentingViewController: UIViewController, nonTransactionalIntentType: NonTransactionalIntentType, completion: @escaping ((Bool, Error?) -> Void)) {
        self.presentingViewController = presentingViewController
        self.transactionIntent = false
        
        switch nonTransactionalIntentType {
            case .logout:
                self.logoutCompletion = completion
            case .showOrders:
                self.genericCompletion = completion
        }
    }
    
    init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
        self.transactionIntent = false
    }
    
    func start() {
        let model = BrokerSelectModel()
        viewModel = BrokerSelectViewModel(model: model, transactionId: transactionId!,transactionIntent: transactionIntent)
        launchBrokerChooser(viewModel)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return CustomPresentAnimationController()
    }
    
    func logout() {
        let model = BrokerSelectModel()
        viewModel = BrokerSelectViewModel(isLogout: true,model:model)
        launchBrokerChooser(viewModel)
    }
    
    func showOrders() {
        let model = BrokerSelectModel()
        viewModel = BrokerSelectViewModel(showOrders: true, model: model)
        launchBrokerChooser(viewModel)
    }
    
    func launchBrokerChooser(_ viewModel: BrokerSelectViewModelProtocol) {
        
        viewModel.coordinatorDelegate = self
        
        brokerChooserViewController = BrokerChooserViewController(viewModel: viewModel)
        brokerChooserViewController.modalPresentationStyle = .overFullScreen
        brokerChooserViewController.transitioningDelegate = self
        presentingViewController.present(brokerChooserViewController, animated: false, completion: nil)
    }
    
    func processBrokerPlatformRedirection(_ redirectUrl: URL) {
        viewModel.processBPRedirectionFromHostApp(withRedirectUrl: redirectUrl)
    }
    
    internal func handleNativeLoginRedirection(_ redirectUrl: URL) {
        viewModel.processBPRedirectionFromHostApp(withRedirectUrl: redirectUrl)
    }
}

extension BrokerSelectCoordinator: BrokerSelectCoordinatorVMDelegate {
    
    func getParentViewController() -> UIViewController {
        return self.presentingViewController
    }
    
    func transactionCompleted(transactionId: String, transactionData: TransactionIntent, authToken: String) {
        dismissBrokerSelect{ [weak self] in
            guard let self = self else { return }
            
            if self.transactionCompletion != nil {
                self.transactionCompletion!(.success(transactionData))
            }
            
            else if self.objcTransactionCompletion != nil {
                       switch transactionData {
                        
                           case let .subscription(response):
                               self.objcTransactionCompletion!(_ObjCTransactionIntentSubscription(response), nil)
                       
                           case let .transaction(authToken, transactionData):
                               self.objcTransactionCompletion!(_ObjcTransactionIntentTransaction(authToken, transactionData), nil)
                           
                           case let .mfTransaction(data):
                                self.objcTransactionCompletion!(_ObjcMfTransactionIntentTransaction(data), nil)
                        
                           case let .connect(response):
                               self.objcTransactionCompletion!(_ObjCTransactionIntentConnect(response), nil)
                  
                           case let .holdingsImport(authToken, broker, status, transactionId, signup):
                               self.objcTransactionCompletion!(_ObjcTransactionIntentHoldingsImport(authToken, status, broker, transactionId, signup), nil)
                        
                           case let .authoriseHoldings(smallcaseAuthToken, status, transactionId, signup):
                               self.objcTransactionCompletion!(_ObjcTransactionIntentAuthoriseHoldings(smallcaseAuthToken, status,transactionId, signup), nil)
                       
                           case let .fetchFunds(smallcaseAuthToken, fund, transactionId, signup):
                               self.objcTransactionCompletion!(_ObjcTransactionIntentFetchFunds(smallcaseAuthToken, fund, transactionId, signup), nil)
                        
                           case let .sipSetup(smallcaseAuthToken, sipAction, transactionId, signup):
                               self.objcTransactionCompletion!(_ObjcTransactionIntentSipSetup(smallcaseAuthToken, sipAction, transactionId, signup), nil)
                               
                           case let .cancelAMO(response):
                               self.objcTransactionCompletion!(_ObjCTransactionIntentCancelAmo(response), nil)
                       case let .onboarding(response):
                           self.objcTransactionCompletion!(_ObjCTransactionIntentOnboarding(response), nil)
                       default: return
                       }
                       
                   }
        }
    }
    
    func transactionErrored(error: TransactionError, successData: Transaction.SuccessData?) {
        
        var responseError = error
        
        if let successData = successData {
            if let transactionError = TransactionError(rawValue: error.rawValue, transactionData: successData) {
                responseError = transactionError
            } else {
                responseError = TransactionError(rawValue: error.rawValue, message: error.message, transactionSuccess: successData)!
            }
        }
        
        SCGateway.shared.registerMixpanelEvent(
            eventName: MixpanelConstants.EVENT_BP_RESPONSE_TO_PARTNER,
            additionalProperties: [
                "transactionId": SessionManager.currentTransactionId ?? "NA",
                "transactionStatus": SessionManager.currentTransactionIdStatus?.status ?? "NA",
                "intent": SessionManager.currentIntentString ?? "NA",
                "error_code": responseError.rawValue,
                "error_message": responseError.message
            ])
        
        dismissBrokerSelect{ [weak self] in
            guard let self = self else { return }
            
            if let transactionCompletion = self.transactionCompletion {
                transactionCompletion(.failure(responseError))
            }
            else if let objcTransactionCompletion = self.objcTransactionCompletion {
                objcTransactionCompletion(nil, ObjcTransactionError(error: responseError))
            }
        }
    }
    
    
    func logoutSuccessful() {
        dismissBrokerSelect{ [weak self] in
                   guard let self = self else { return }
           self.dismissTopMostViewController()
           self.brokerChooserViewController = nil
           self.logoutCompletion!(true,nil)
        }
    }
    
    func dismissTopMostViewController() {
        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let window = windowScene.windows.first(where: { $0.isKeyWindow }),
           let topController = window.rootViewController {
            topController.dismiss(animated: true)
        }
    }


    
    func logoutFailed(error: Error) {
        dismissBrokerSelect{ [weak self] in
            guard let self = self else { return }
            if self.logoutCompletion != nil {
                self.logoutCompletion!(false,error)
            }
        }
    }
    
    func nonTransactionalIntentCompleted(success: Bool, error: Error?) {
        
        SessionManager.showOrders = false
        
        dismissBrokerSelect{ [weak self] in
            
            guard let self = self else { return }
            
            if let genericCompletion = self.genericCompletion {
                genericCompletion(success, error)
            }
        }
    }
    
    func dismissBrokerSelect(completion: (() -> Void)?) {
        
        if SessionManager.userStatus == .guest {
            SessionManager.broker = nil
        }
        
        DispatchQueue.main.async {
            UIView.animateKeyframes(withDuration: 0.3, delay: 0, options: [.beginFromCurrentState], animations: {

                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.3, animations: {
                    self.brokerChooserViewController.webView.frame.origin.y += 32
                    self.brokerChooserViewController.webView.alpha = 0
                })
                
            }, completion:{ _ in
                
                self.brokerChooserViewController.dismiss(animated: false, completion: {
                    completion?()
                })
                
            })
        }
    }
    
    func launchLeadGen(_ leadGenView: UIViewController, completion: (() -> Void)?) {
        
        self.brokerChooserViewController.smallcaseLoaderImageView.isHidden = false
        
        DispatchQueue.main.async {
            
            UIView.animateKeyframes(withDuration: 0.3, delay: 0, options: [.beginFromCurrentState], animations: {
                
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.3, animations: {
                    self.brokerChooserViewController.webView.alpha = 0
                    self.brokerChooserViewController.webView.frame.origin.y += 32
                })
                
            }, completion:{ _ in
                
                leadGenView.view.backgroundColor = .clear
                self.brokerChooserViewController.present(leadGenView, animated: false, completion: nil)
                
            })
            
        }
    }
        
    
}

