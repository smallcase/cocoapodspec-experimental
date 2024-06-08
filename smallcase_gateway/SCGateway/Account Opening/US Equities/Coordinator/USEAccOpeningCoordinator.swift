//
//  USEAccOpeningCoordinator.swift
//  SCGateway
//
//  Created by Ankit Deshmukh on 17/10/22.
//  Copyright © 2022 smallcase. All rights reserved.
//

import Foundation

class USEAccOpeningCoordinator: NSObject, USECoordinator {
    
    var presentingViewController: UIViewController
    
    var useAccOpeningViewController: USEAccOpeningViewController!
    
    var viewModel: USEAccOpeningViewModelProtocol!
    
    var useAccountOpeningCompletion: ((String?, Error?) -> Void)? = nil
    
    init(_ presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
        viewModel = USEAccOpeningViewModel()
    }
    
    init(_ presentingViewController: UIViewController, _ signUpConfig: SignUpConfig?) {
        self.presentingViewController = presentingViewController
        viewModel = USEAccOpeningViewModel(signUpConfig)
    }
    
    init(_ presentingViewController: UIViewController, _ signUpConfig: SignUpConfig?, _ completion: @escaping ((String?, Error?) -> Void)) {
        self.presentingViewController = presentingViewController
        self.useAccountOpeningCompletion = completion
        viewModel = USEAccOpeningViewModel(signUpConfig)
    }
    
    init(_ presentingViewController: UIViewController,
         _ signUpConfig: SignUpConfig?,
         _ additionalConfig: [String: Any]?,
         _ completion: @escaping ((String?, Error?) -> Void)) {
        
        self.presentingViewController = presentingViewController
        self.useAccountOpeningCompletion = completion
        viewModel = USEAccOpeningViewModel(signUpConfig, additionalConfig)
    }
    
    init(_ presentingViewController: UIViewController,
         _ signUpConfig: SignUpConfig?,
         _ additionalConfig: [String: Any]?) {
        
        self.presentingViewController = presentingViewController
        viewModel = USEAccOpeningViewModel(signUpConfig, additionalConfig)
    }
    
    
    func start() {
        viewModel.coordinatorDelegate = self
        
        useAccOpeningViewController = USEAccOpeningViewController(viewModel)
        useAccOpeningViewController.modalPresentationStyle = .overFullScreen
        
        presentingViewController.present(useAccOpeningViewController, animated: false, completion: nil)
    }
    
    func submitLeadResponseAndFinish(leadStatusResponse: Data? = nil, error: Error? = nil) {
        
        DispatchQueue.main.async {
            
            self.useAccOpeningViewController.dismiss(animated: false, completion: {
                
                if let accountOpeningCompletion = self.useAccountOpeningCompletion {
                    
                    if let leadStatusApiData = leadStatusResponse,
                       let leadStatusDict = leadStatusApiData.toJson(),
                       let leadStatusSuccessData = leadStatusDict["data"] as? [String: Any],
                       let leadStatusJsonString = leadStatusSuccessData.toJsonString {
                        accountOpeningCompletion(leadStatusJsonString, error)
                    } else {
                        accountOpeningCompletion(nil, error)
                    }
                    
                }
            })
            
        }
    }
}
