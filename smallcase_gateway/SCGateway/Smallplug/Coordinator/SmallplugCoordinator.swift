//
//  SmallplugCoordinator.swift
//  SCGateway
//
//  Created by Ankit Deshmukh on 28/07/21.
//  Copyright © 2021 smallcase. All rights reserved.
//

class SmallplugCoordinator: NSObject, Coordinator {
    
    //MARK: Variables
    
    var smallPlugCompletion: ((Any?, Error?) -> Void)?
    
    var presentingViewController: UIViewController
    
    var smallPlugViewController: SmallPlugViewController!
    
    var viewModel: SmallplugViewModelProtocol!
    
    //MARK: Init
    
    init(presentingViewController: UIViewController,completion: @escaping ((Any?, Error?) -> Void)){
        self.presentingViewController = presentingViewController
        self.smallPlugCompletion = completion
    }
    
    func start() {
        viewModel = SmallplugViewModel()
        viewModel.smallplugCoordinatorDelegate = self
        smallPlugViewController = SmallPlugViewController(showSmallcaseLoader: true, viewModel: viewModel)
        smallPlugViewController.modalPresentationStyle = .overFullScreen
        presentingViewController.present(smallPlugViewController, animated: false, completion: nil)
    }
    
    func start(_ smallplugUiConfig: SmallplugUiConfig?) {
        viewModel = SmallplugViewModel(smallplugUiConfig: smallplugUiConfig)
        viewModel.smallplugCoordinatorDelegate = self
        
        smallPlugViewController = SmallPlugViewController(showSmallcaseLoader: true, viewModel: viewModel)
        smallPlugViewController.modalPresentationStyle = .overFullScreen
        
        presentingViewController.present(smallPlugViewController, animated: false, completion: nil)
    }
}

extension SmallplugCoordinator: SmallplugCoordinatorVMDelegate {
    
    func smallplugFinished() {
        
        DispatchQueue.main.async {
            
            self.smallPlugViewController.dismiss(animated: false, completion: {
                [weak self] in
                
                guard let self = self else { return }
                
                if let smallplugCompletion = self.smallPlugCompletion {
                    smallplugCompletion(SessionManager.sdkToken, nil)
                }
            })
            
        }
        
    }
    
}
