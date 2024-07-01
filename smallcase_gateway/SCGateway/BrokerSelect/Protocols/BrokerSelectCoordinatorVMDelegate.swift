//
//  BrokerSelectCoordinatorVMDelegate.swift
//  SCGateway
//
//  Created by Ankit Deshmukh on 02/05/22.
//  Copyright © 2022 smallcase. All rights reserved.
//

import Foundation

protocol BrokerSelectCoordinatorVMDelegate: AnyObject {
    
    func launchLeadGen(_ leadGenView: UIViewController, completion: (() -> Void)?)
    func dismissBrokerSelect(completion: (() -> Void)?)
    
    func transactionCompleted(transactionId: String, transactionData: TransactionIntent, authToken: String)
    func transactionErrored(error: TransactionError, successData: Transaction.SuccessData?)
    
    func getParentViewController() -> UIViewController
    
    func logoutSuccessful()
    func logoutFailed(error:Error)
    
    func nonTransactionalIntentCompleted(success: Bool, error: Error?)
}

