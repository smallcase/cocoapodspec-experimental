//
//  LeadGenViewController.swift
//  WebViewTester
//
//  Created by Dip on 10/08/20.
//  Copyright © 2020 smallcase. All rights reserved.
//

import Foundation
import UIKit
import SCGateway


class LeadGenViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var contactTextField: UITextField!
    
    
    @IBOutlet weak var pincodeTextField: UITextField!
    
    @IBOutlet weak var logoutButton: UIButton!
    
    
    @IBAction func onClickTriggerLeadGen(_ sender: Any) {
        var params:[String:String] = [:]
        params["name"] = nameTextField.text
        params["email"] = emailTextField.text
        params["contact"] = contactTextField.text
        params["pinCode"] = pincodeTextField.text
        
        SCGateway.shared.triggerLeadGen(presentingController: self,params: params)
    }
    
    @IBAction func logoutButtonClicked(_ sender: UIButton) {
        
        SCGateway.shared.logoutUser(presentingController: self, completion: { (success, error) in
            
            if(success) {
                
                self.showPopup(title: "Success", msg: "Logout Successful")
                
            } else {
                
                self.showPopup(title: "Success", msg: "Logout Failed \(error.debugDescription)")
                
            }
            
        })
        
    }
    
}
