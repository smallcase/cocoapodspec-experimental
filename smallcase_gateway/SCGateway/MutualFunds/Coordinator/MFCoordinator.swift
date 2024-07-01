//
//  MFCoordinator.swift
//  SCGateway
//
//  Created by Indrajit Roy on 08/09/22.
//  Copyright © 2022 smallcase. All rights reserved.
//

import Foundation

class MFCoordinator: NSObject, Coordinator {
    
    //MARK:- Variables
    
    var mfCompletion: ((Result<TransactionIntent, TransactionError>) -> Void)?
    var mfCompletionObjC: ((Any?, ObjcTransactionError?) -> Void)?
    
    var presentingViewController: UIViewController
    
    var mfViewController: MFViewController!
    
    var viewModel: MFViewModel!
    
    var transactionId: String
    
    //MARK: Init
    
    init(presentingViewController: UIViewController, transactionId: String, completion: @escaping (Result<TransactionIntent, TransactionError>) -> Void){
        self.presentingViewController = presentingViewController
        self.transactionId = transactionId
        self.mfCompletion = completion
        self.mfCompletionObjC = nil
    }
    
    init(presentingViewController: UIViewController, transactionId: String, completion: @escaping (Any?, ObjcTransactionError?) -> Void){
        self.presentingViewController = presentingViewController
        self.transactionId = transactionId
        self.mfCompletion = nil
        self.mfCompletionObjC = completion
    }
    
    func start() {
        viewModel = MFViewModel(transactionId: transactionId, completion: onPartnerResponseReceived(response:))
        mfViewController = MFViewController(viewModel: viewModel)
        mfViewController.modalPresentationStyle = .overFullScreen
        presentingViewController.present(mfViewController, animated: false, completion: nil)
    }
    
    func onPartnerResponseReceived(response: SdkPartnerResponse) -> Void {
        if response is MFSuccessResponse {
            mfCompletion?(.success(.mfHoldingsImport(data: response.data)))
            mfCompletionObjC?(_ObjCTransactionIntentMfHoldingsImport(response.data), nil)
        } else if response is MFErrorResponse {
            let e = (response as? MFErrorResponse)?.txnError ?? .apiError
            mfCompletion?(.failure(e))
            mfCompletionObjC?(nil, ObjcTransactionError(error: e))
        }
        DispatchQueue.main.async {
            self.mfViewController.dismiss(animated: false)
        }
        
    }
}

protocol SdkPartnerResponse {
    var success: Bool { get }
    var data: String? { get }
}

class MFSuccessResponse : SdkPartnerResponse {
    var success: Bool {
        get { true }
    }
    
    var data: String?
    init(data: String?) {
        self.data = data
    }
}

class MFErrorResponse : SdkPartnerResponse {
    var success: Bool {
        get { false }
    }
    
    var txnError: TransactionError
    
    var errorCode: Int { get { txnError.rawValue } }
    var errorMessage: String { get { txnError.message } }
    var data: String? { get { txnError.data } }
    
    init(txnError: TransactionError) {
        self.txnError = txnError
    }
}
