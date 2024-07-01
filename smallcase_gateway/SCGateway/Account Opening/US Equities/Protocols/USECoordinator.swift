//
//  USECoordinator.swift
//  SCGateway
//
//  Created by Ankit Deshmukh on 13/12/22.
//  Copyright © 2022 smallcase. All rights reserved.
//

import Foundation

protocol USECoordinator: AnyObject {
    
    func start()
    
    func submitLeadResponseAndFinish(leadStatusResponse: Data?, error: Error?)
}
