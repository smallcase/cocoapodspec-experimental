//
//  ViewModelToUIViewControllerDelegate.swift
//  Loans
//
//  Created by Ankit Deshmukh on 22/05/23.
//

import Foundation

protocol ViewModelUIViewControllerDelegate {
    
    //TODO: Add any other UIState via enum
    func updateState(showLoadingView: Bool)
    
}
