//
//  SmallplugViewModelProtocol.swift
//  SCGateway
//
//  Created by Ankit Deshmukh on 28/07/21.
//  Copyright © 2021 smallcase. All rights reserved.
//

import UIKit

protocol SmallplugViewModelProtocol: AnyObject {
    
    var uiConfig: SmallplugUiConfig? { get set }
    
    func dismissSmallPlug()
    
    var smallplugCoordinatorDelegate: SmallplugCoordinatorVMDelegate? { get set }
    
    func getSmallplugLaunchURL() -> URLRequest
    
    func isUrlValidForLaunch(_ urlString: String) -> Bool
}
