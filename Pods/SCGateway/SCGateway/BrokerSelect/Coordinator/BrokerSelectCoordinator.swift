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
    
    var objcTransactionCompletion: ((Any?, Error?) -> Void)?
    
    var presentingViewController: UIViewController
    
    var safariViewController: SFSafariViewController!
    
    // var webAuthController: AuthenticationSession!
    
    var gatewayFlowViewController: GatewayFlowViewController!
    
    var viewModel: BrokerSelectViewModelProtocol!


    init(presentingViewController: UIViewController, transactionId: String, completion: @escaping (Result<TransactionIntent, TransactionError>) -> Void) {

        self.presentingViewController = presentingViewController
        self.transactionId = transactionId
        self.transactionCompletion = completion
        self.objcTransactionCompletion = nil
    }
    //OBJC COmpatible
    init(presentingViewController: UIViewController, transactionId: String, completion: @escaping (Any?, Error?) -> Void) {

        self.presentingViewController = presentingViewController
        self.transactionId = transactionId
        self.objcTransactionCompletion = completion
        self.transactionCompletion = nil
    }
    
    func start() {
       
        let model = BrokerSelectModel()
        viewModel = BrokerSelectViewModel(model: model, transactionId: transactionId!)
        viewModel.coordinatorDelegate = self
        gatewayFlowViewController = GatewayFlowViewController(viewModel: viewModel)
        gatewayFlowViewController.modalPresentationStyle = .overCurrentContext
        presentingViewController.present(gatewayFlowViewController, animated: false, completion: nil)
    }
}



extension BrokerSelectCoordinator: BrokerSelectCoordinatorVMDelegate {
    
    func transactionCompleted(transactionId: String, transactionData: TransactionIntent, authToken: String) {
        if transactionCompletion != nil {
            transactionCompletion!(.success(transactionData))
        }
        else if objcTransactionCompletion != nil {
            switch transactionData {
            case let .transaction(authToken, transactionData):
                objcTransactionCompletion!(_ObjcTransactionIntentTransaction(authToken, transactionData), nil)
            case let .connect(authToken, transactionData):
                objcTransactionCompletion!(_ObjCTransactionIntentConnect(authToken, transactionData), nil)
                
            case let .holdingsImport(authToken, status):
                objcTransactionCompletion!(_ObjcTransactionIntentHoldingsImport(authToken, status), nil)
            }
            
        }
          
    }
    
    func transactionErrored(transactionId: String, error: TransactionError) {
        
        if transactionCompletion != nil {
            transactionCompletion!(.failure(error))
        }
        else if objcTransactionCompletion != nil {
            objcTransactionCompletion!(nil, error)
        }
         
    }

    
    func dismissBrokerSelect() {
            DispatchQueue.main.async { [weak self] in
            self?.gatewayFlowViewController.dismiss(animated: false, completion: nil)
        }
       
    }
        
    
}



