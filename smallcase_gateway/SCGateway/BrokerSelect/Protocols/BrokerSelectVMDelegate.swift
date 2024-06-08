//
//  BrokerSelectVMDelegate.swift
//  SCGateway
//
//  Created by Ankit Deshmukh on 02/05/22.
//  Copyright © 2022 smallcase. All rights reserved.
//

import Foundation

protocol BrokerSelectVMDelegate: AnyObject {
    
    func showBrokerSelector()
    
    func changeState(to viewState: ViewState, completion: ((Bool) -> Void)?)
    
    func leprechaunStateChanged()
}
