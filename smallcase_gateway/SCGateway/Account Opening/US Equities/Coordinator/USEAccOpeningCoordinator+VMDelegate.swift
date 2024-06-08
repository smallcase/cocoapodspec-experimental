//
//  USEAccOpeningCoordinator+VMDelegate.swift
//  SCGateway
//
//  Created by Ankit Deshmukh on 17/10/22.
//  Copyright © 2022 smallcase. All rights reserved.
//

import Foundation

extension USEAccOpeningCoordinator: USEAccOpeningCoordinatorVMDelegate {
    
    func completedUSEAccountOpeningFlow() {
        DispatchQueue.main.async {
            
            self.useAccOpeningViewController.dismiss(animated: false, completion: nil)
            
        }
    }
}
