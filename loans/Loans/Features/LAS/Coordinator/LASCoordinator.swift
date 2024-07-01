//
//  LASCoordinator.swift
//  Loans
//
//  Created by Ankit Deshmukh on 04/05/23.
//

import Foundation
import UIKit

class LASCoordinator: NSObject{
    
    var parentViewControllerForLAS: UIViewController
    var loadingScreen: LoadingScreenViewController!
    
    var viewModel: LASViewModelProtocol!
    
    var lasCompletion: ((ScLoanResult<ScLoanSuccess>) -> Void)?
    var objcLasCompletion: ((ScLoanSuccess?, ScLoanError?) -> Void)?
    
    init(_ parentViewController: UIViewController, _ completion: ((ScLoanResult<ScLoanSuccess>) -> Void)? = nil) {
        self.parentViewControllerForLAS = parentViewController
        self.lasCompletion = completion
    }
    
    init(_ parentViewController: UIViewController, _ completion: ((ScLoanSuccess?, ScLoanError?) -> Void)? = nil) {
        self.parentViewControllerForLAS = parentViewController
        self.objcLasCompletion = completion
    }
    
    func launchLoadingScreen() {
        viewModel = LASViewModel()
        viewModel.coordinatorDelegate = self
        
        //prepare loading screen instance
        loadingScreen = LoadingScreenViewController(viewModel)
        loadingScreen.modalPresentationStyle = .overFullScreen
        loadingScreen.transitioningDelegate = self
        
        //launch loading screen on top of parent view controller
        parentViewControllerForLAS.present(loadingScreen, animated: false, completion: nil)
    }
    
    func dismissLoadingScreen(_ response: String?, _ error: ScLoanError?) {
        DispatchQueue.main.async {
            self.loadingScreen.dismiss(animated: false) { [weak self] in
                guard let self = self else { return }
                
                if let successResponse = response {
                    self.lasCompletion?(.success(ScLoanSuccess(data: successResponse)))
                    self.objcLasCompletion?(ScLoanSuccess(data: successResponse), nil)
                    return
                }
                
                //TODO: update error response with error codes
                if let errorResponse = error {
                    let errorResponseToHost = ScLoanError(errorCode: errorResponse.code, errorMessage: errorResponse.errorMessage, data: errorResponse.data)
                    self.lasCompletion?(.failure(errorResponseToHost))
                    self.objcLasCompletion?(nil, errorResponseToHost)
                }
            }
        }
    }
}

//MARK: Coordinator VM Delegate
extension LASCoordinator: LASCoordinatorVMDelegate {
    
    func concludeLOSJourney(_ result: ScLoanResult<ScLoanSuccess>) {
        switch result {
        case .success(let success):
            ScLoan.instance.registerMixpanelEvent(eventName: MixpanelConstants.EVENT_RESPONSE_SENT_TO_PARTNER,
                                                  additionalProperties: [
                                                    "code": success.code,
                                                    "message": success.message,
                                                    "data": success.data
                                                  ])
            dismissLoadingScreen(success.data, nil)
        case .failure(let error):
            ScLoan.instance.registerMixpanelEvent(eventName: MixpanelConstants.EVENT_RESPONSE_SENT_TO_PARTNER,
                                                  additionalProperties: [
                                                    "code": error.errorCode,
                                                    "message": error.errorMessage,
                                                    "data": error.data
                                                  ])
            dismissLoadingScreen(nil, error)
        }
    }
    
}

//MARK: Transitioning Delegate
extension LASCoordinator: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomPresentAnimationController()
    }
}
