//
//  USEAccOpeningViewModelProtocol.swift
//  SCGateway
//
//  Created by Ankit Deshmukh on 17/10/22.
//  Copyright © 2022 smallcase. All rights reserved.
//

import Foundation

protocol USEAccOpeningViewModelProtocol : AnyObject {
    
    var coordinatorDelegate: USEAccOpeningCoordinatorVMDelegate? { get set }
    
    func launchCustomTab()
    
    @available(iOS 13.0, *)
    var webPresentationContextProvider: Any? {get set }
}
