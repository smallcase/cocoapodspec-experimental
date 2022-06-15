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
    
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBOutlet weak var utmSourceTextField: UITextField!
    
    @IBOutlet weak var utmCampaignTextField: UITextField!
    
    @IBOutlet weak var utmMediumTextField: UITextField!
    
    @IBOutlet weak var utmContentTextField: UITextField!
    
    @IBOutlet weak var utmTermTextField: UITextField!
    
    @IBOutlet weak var utmBTextField: UITextField!
    
    @IBOutlet weak var isRetargeting: UISwitch!
    
    lazy var tapRecognizer: UITapGestureRecognizer = {
        var recognizer = UITapGestureRecognizer(target:self, action: #selector(dismissKeyboard))
        return recognizer
    }()
    
    override func viewDidLoad() {
        
        nameTextField.delegate = self
        emailTextField.delegate = self
        contactTextField.delegate = self

        utmSourceTextField.delegate = self
        utmMediumTextField.delegate = self
        utmCampaignTextField.delegate = self
        utmContentTextField.delegate = self
        utmTermTextField.delegate = self
        utmBTextField.delegate = self
    }
    
    @IBAction func onClickTriggerLeadGen(_ sender: Any) {
        var params:[String:String] = [:]
        params["name"] = nameTextField.text
        params["email"] = emailTextField.text
        params["contact"] = contactTextField.text
        
        var map:[String:String] = [:]
        map["utm_source"] = utmSourceTextField.text
        map["utm_medium"] = utmMediumTextField.text
        map["utm_campaign"] = utmCampaignTextField.text
        map["utm_content"] = utmContentTextField.text
        map["utm_term"] = utmTermTextField.text
        map["utm_b"] = utmBTextField.text
        
//        let retargeting = isRetargeting.isOn
        
//        SCGateway.shared.triggerLeadGen(presentingController: self,params: params, utmParams: map, retargeting: retargeting)
        
        SCGateway.shared.triggerLeadGen(presentingController: self, params: params, completion: { (response) in
            
            self.showPopup(title: "LeadGenResponse", msg: response)
        })
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
    
    @IBAction func initWealthModule(_ sender: UIButton) {

        SCGateway.shared.launchSmallPlug(presentingController: self, smallplugData: SmallplugData(nil,nil), smallplugUiConfig: SmallplugUiConfig(
            smallplugHeaderColor: "2F363F",
            headerColorOpacity: 1,
            backIconColor: "FFFFFF",
            backIconColorOpacity: 1
        )) {
            (response, error) in

            if(response != nil) {

                self.showPopup(title: "Success", msg: response.debugDescription)

            } else {

                self.showPopup(title: "Error", msg: error?.localizedDescription)

            }
        }
        
//        SCGateway.shared.launchSmallPlug(presentingController: self, smallplugData: SmallplugData(nil,nil)) {
//            (response, error) in
//
//            if(response != nil) {
//
//                self.showPopup(title: "Success", msg: response.debugDescription)
//
//            } else {
//
//                self.showPopup(title: "Error", msg: error?.localizedDescription)
//
//            }
//        }
    }
}

extension LeadGenViewController: UITextFieldDelegate {
    
    @objc func dismissKeyboard() {
        nameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        contactTextField.resignFirstResponder()
//        pincodeTextField.resignFirstResponder()
        
        utmSourceTextField.resignFirstResponder()
        utmMediumTextField.resignFirstResponder()
        utmCampaignTextField.resignFirstResponder()
        utmContentTextField.resignFirstResponder()
        utmTermTextField.resignFirstResponder()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        view.addGestureRecognizer(tapRecognizer)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        view.removeGestureRecognizer(tapRecognizer)
        
        
    }
}
