//
//  LASViewModelProtocol.swift
//  Loans
//
//  Created by Ankit Deshmukh on 06/05/23.
//

import Foundation
import AuthenticationServices

protocol LASViewModelProtocol {
    
    //MARK: Variables
    @available(iOS 13.0, *)
    var webPresentationContextProvider: Any? {get set }
    var coordinatorDelegate: LASCoordinatorVMDelegate? { get set }
    var viewControllerDelegate: ViewModelUIViewControllerDelegate? {get set}
    
    //MARK: Methods
    func getLenderInfo() -> LenderInfo?
    func authenticateInteraction()
    func launchLOSJourney()
}
