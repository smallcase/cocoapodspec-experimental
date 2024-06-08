//
//  BrokerChooserViewController+BrokerSelectVMDelegate.swift
//  SCGateway
//
//  Created by Ankit Deshmukh on 29/06/22.
//  Copyright © 2022 smallcase. All rights reserved.
//

import Foundation
import SafariServices

extension BrokerChooserViewController: BrokerSelectVMDelegate {
    
    func leprechaunStateChanged() {
        let msg = SessionManager.isLeprechaunActive ? Constants.leprechaunActiveMessage : Constants.leprechaunInactiveMessage
        
        DispatchQueue.main.async { [weak self] in
            self?.showToast(message: msg, font: .systemFont(ofSize: 14))
        }
        
    }
    
    func changeState(to viewState: ViewState, completion: ((Bool) -> Void)?) {
        transactionCompletion = completion
        DispatchQueue.main.async { [weak self] in
            self?.viewState = viewState
        }
    }
    
    func showBrokerSelector() {
        DispatchQueue.main.async { [weak self] in
            self?.viewState = .brokerSelect
        }
    }
}
