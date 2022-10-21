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
    
    @IBOutlet weak var smallplugPath: UITextField!
    
    @IBOutlet weak var smallplugParam: UITextField!
    
    @IBOutlet weak var showLoginCtaSwitch: UISwitch!
    

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
        
        smallplugPath.delegate = self
        smallplugParam.delegate = self
    }
    
    @IBAction func onClickTriggerLeadGen(_ sender: Any) {
        var params:[String:String] = [:]
        params["name"] = nameTextField.text
        params["email"] = emailTextField.text
        params["contact"] = contactTextField.text
        
        var map:[String:String] = [:]
        map["utm_source"] = utmSourceTextField.text
        map["utm_medium"] = utmMediumTextField.text
//        map["utm_campaign"] = utmCampaignTextField.text
//        map["utm_content"] = utmContentTextField.text
//        map["utm_term"] = utmTermTextField.text
//        map["utm_b"] = utmBTextField.text
        
//        let retargeting = isRetargeting.isOn
        
//        SCGateway.shared.triggerLeadGen(presentingController: self,params: params, utmParams: map, retargeting: retargeting)
        
//        SCGateway.shared.triggerLeadGen(presentingController: self, params: params, completion: { (response) in
//
//            self.showPopup(title: "LeadGenResponse", msg: response)
//        })
        
        SCGateway.shared.triggerLeadGen(
            presentingController: self,
            params: params,
            utmParams: nil,
            retargeting: false,
            showLoginCta: showLoginCtaSwitch.isOn,
            completion: { (response) in

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

        var headerColor = utmCampaignTextField.text ?? "2F363F"
        
        if headerColor.isEmpty {
            headerColor = "2F363F"
        }
        
        var headColorOpacity = utmContentTextField.text ?? "1.0"
        
        if headColorOpacity.isEmpty {
            headColorOpacity = "1.0"
        }
        
        var backIconColor = utmTermTextField.text ?? "FFFFFF"
        
        if backIconColor.isEmpty {
            backIconColor = "FFFFFF"
        }
        
        var backIconColorOpacity = utmBTextField.text ?? "1.0"
        
        if backIconColorOpacity.isEmpty {
            backIconColorOpacity = "1.0"
        }
        
        SCGateway.shared.launchSmallPlug(
            presentingController: self,
            smallplugData: SmallplugData(smallplugPath.text, smallplugParam.text),
            smallplugUiConfig: SmallplugUiConfig(
            smallplugHeaderColor: headerColor,
            headerColorOpacity: Double(headColorOpacity) as NSNumber?,
            backIconColor: backIconColor,
            backIconColorOpacity: Double(backIconColorOpacity) as NSNumber?
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

    @IBAction func launchUSEAccountOpening(_ sender: UIButton) {
        
//        SCGateway.shared.openUsEquitiesAccount(presentingController: self)
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
        
        smallplugPath.resignFirstResponder()
        smallplugParam.resignFirstResponder()
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
