//
//  USEAccOpeningViewController.swift
//  SCGateway
//
//  Created by Ankit Deshmukh on 12/10/22.
//  Copyright © 2022 smallcase. All rights reserved.
//

import UIKit
import AuthenticationServices

class USEAccOpeningViewController: UIViewController {

    fileprivate lazy var gatewayAuthProvider: Any? = nil
    
    private var viewModel: USEAccOpeningViewModelProtocol!
    
    init(_ viewModel: USEAccOpeningViewModelProtocol) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        if #available(iOS 13.0, *) {
            self.viewModel.webPresentationContextProvider = self
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.launchCustomTab()
    }
    
}

extension USEAccOpeningViewController: ASWebAuthenticationPresentationContextProviding {
    @available(iOS 13.0, *)
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.keyWindow!.windowScene else { fatalError("No Key Window Scene")}
        return ASPresentationAnchor(windowScene: windowScene )
    }
}
