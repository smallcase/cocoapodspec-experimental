//
//  SmartInvestingLaunchScreen.swift
//  WebViewTester
//
//  Created by Ankit Deshmukh on 11/05/23.
//  Copyright © 2023 smallcase. All rights reserved.
//

import UIKit
import SwiftUI
import SCGateway
import Loans

class SmartInvestingLaunchScreen: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Launch Screen"
        // Do any additional setup after loading the view.
    }
    
    @IBAction func launchLoansModule(_ sender: UIButton) {
        
        if #available(iOS 15.0, *) {
//            let lasView = LASScreen()
//            let hostingController = UIHostingController(rootView: lasView)
            
//            let newLasUserView = CreateUserScreen()
//            let hostingController = UIHostingController(rootView: newLasUserView)
//            navigationController?.pushViewController(hostingController, animated: true)
            
            let hostingController = CreateUserScreen().embeddedInHostingController()
            navigationController?.pushViewController(hostingController, animated: true)
        } else {
            self.showPopup(title: "Error", msg: "This module is currently supported only on iOS 15+")
        }
        
    }

}
