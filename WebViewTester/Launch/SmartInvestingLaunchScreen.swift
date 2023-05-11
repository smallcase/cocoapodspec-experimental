//
//  SmartInvestingLaunchScreen.swift
//  WebViewTester
//
//  Created by Ankit Deshmukh on 11/05/23.
//  Copyright © 2023 smallcase. All rights reserved.
//

import UIKit
import SwiftUI

class SmartInvestingLaunchScreen: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func launchLoansModule(_ sender: UIButton) {
        
        if #available(iOS 13.0, *) {
            let lasView = LASScreen()
            let hostingController = UIHostingController(rootView: lasView)
//            present(hostingController, animated: true, completion: nil)
            UIApplication.shared.windows.first?.rootViewController = hostingController
        } else {
            self.showPopup(title: "Error", msg: "This module is currently only supported on iOS 13+")
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
