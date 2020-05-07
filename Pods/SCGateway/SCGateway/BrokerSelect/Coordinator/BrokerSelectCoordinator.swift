//
//  BrokerSelectCoordinator.swift
//  SCGateway
//
//  Created by Shivani on 07/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import SafariServices

internal class BrokerSelectCoordinator: NSObject, Coordinator {
    
    //MARK:- Controllers
    var transactionId: String?
    
    var transactionCompletion: ((Result<TransactionIntent, TransactionError>) -> Void)?
    
    var objcTransactionCompletion: ((Any?, ObjcTransactionError?) -> Void)?
    
    var presentingViewController: UIViewController
    
    var safariViewController: SFSafariViewController!
    
    // var webAuthController: AuthenticationSession!
    
    var gatewayFlowViewController: GatewayFlowViewController!
    
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
    
    func start() {
       
        let model = BrokerSelectModel()
        viewModel = BrokerSelectViewModel(model: model, transactionId: transactionId!,transactionIntent: transactionIntent)
        viewModel.coordinatorDelegate = self
        gatewayFlowViewController = GatewayFlowViewController(viewModel: viewModel)
        gatewayFlowViewController.modalPresentationStyle = .overCurrentContext
        presentingViewController.present(gatewayFlowViewController, animated: false, completion: nil)
    }
}



extension BrokerSelectCoordinator: BrokerSelectCoordinatorVMDelegate {
    
    func transactionCompleted(transactionId: String, transactionData: TransactionIntent, authToken: String) {
        dismissBrokerSelect{ [weak self] in
            guard let self = self else { return }
            
            if self.transactionCompletion != nil {
                self.transactionCompletion!(.success(transactionData))
                   }
            else if self.objcTransactionCompletion != nil {
                       switch transactionData {
                       case let .transaction(authToken, transactionData):
                        self.objcTransactionCompletion!(_ObjcTransactionIntentTransaction(authToken, transactionData), nil)
                       case let .connect(authToken, transactionData):
                        self.objcTransactionCompletion!(_ObjCTransactionIntentConnect(authToken, transactionData), nil)
                           
                       case let .holdingsImport(authToken, status, transactionId):
                        self.objcTransactionCompletion!(_ObjcTransactionIntentHoldingsImport(authToken, status, transactionId), nil)
                       }
                       
                   }
        }
        
       
          
    }
    
    func transactionErrored(transactionId: String, error: TransactionError) {
        
        print(error)
        
        dismissBrokerSelect{ [weak self] in
            guard let self = self else { return }
            
            if self.transactionCompletion != nil {
                self.transactionCompletion!(.failure(error))
            }
            else if self.objcTransactionCompletion != nil {
                self.objcTransactionCompletion!(nil, ObjcTransactionError(error: error))
            }
        }
        
         
    }

    
    func dismissBrokerSelect(completion: (() -> Void)?) {
            DispatchQueue.main.async { [weak self] in
                self?.gatewayFlowViewController.dismiss(animated: false, completion: nil)
                completion?()
        }
        
}
        
    
}



