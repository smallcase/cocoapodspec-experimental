//
//  USEAOViewController.swift
//  WebViewTester
//
//  Created by Ankit Deshmukh on 04/01/23.
//  Copyright © 2023 smallcase. All rights reserved.
//

import UIKit
import SCGateway
import Foundation

class USEAOViewController: UIViewController {

    //MARK: Variables
    
    @IBOutlet weak var opaqueId: UITextField!
    @IBOutlet weak var notes: UITextField!
    
    @IBOutlet weak var utm_campaign: UITextField!
    @IBOutlet weak var utm_content: UITextField!
    @IBOutlet weak var utm_medium: UITextField!
    @IBOutlet weak var utm_term: UITextField!
    @IBOutlet weak var utm_source: UITextField!
    
    @IBOutlet weak var isRetargeting: UISwitch!
    
    @IBOutlet weak var config_key_1: UITextField!
    @IBOutlet weak var config_val_1: UITextField!
    
    @IBOutlet weak var config_key_2: UITextField!
    @IBOutlet weak var config_val_2: UITextField!
    
    @IBOutlet weak var config_key_3: UITextField!
    @IBOutlet weak var config_val_3: UITextField!
    
    lazy var tapRecognizer: UITapGestureRecognizer = {
        var recognizer = UITapGestureRecognizer(target:self, action: #selector(dismissKeyboard))
        return recognizer
    }()
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        opaqueId.delegate = self
        notes.delegate = self
        
        utm_term.delegate = self
        utm_source.delegate = self
        utm_medium.delegate = self
        utm_content.delegate = self
        utm_campaign.delegate = self
        
        config_key_1.delegate = self
        config_val_1.delegate = self
        
        config_key_2.delegate = self
        config_val_2.delegate = self
        
        config_key_3.delegate = self
        config_val_3.delegate = self
    }
    
    //MARK: Trigger USEAO Flow
    @IBAction func onUSEAOButtonClick(_ sender: Any) {
        
        if let opaqueId = opaqueId.text, !opaqueId.isEmpty {
            
            var configDict : [String: Any] = [:]
            
            if let key1 = config_key_1.text, !key1.isEmpty {
                configDict[key1] = config_val_1.text ?? ""
            }
            
            if let key2 = config_key_2.text, !key2.isEmpty {
                configDict[key2] = config_val_2.text ?? ""
            }
            
            if let key3 = config_key_3.text, !key3.isEmpty {
                configDict[key3] = config_val_3.text ?? ""
            }
            
            SCGateway.shared.openUsEquitiesAccount(
                presentingController: self,
                signUpConfig: SignUpConfig(
                    opaqueId: opaqueId,
                    notes: notes.text,
                    utmParams: UtmParams(
                        utmSource: utm_source.text,
                        utmMedium: utm_medium.text,
                        utmCampaign: utm_campaign.text,
                        utmContent: utm_content.text,
                        utmTerm: utm_term.text
                    ),
                    retargeting: isRetargeting.isOn
                ),
                additionalConfig: configDict
            ) { result, error in
                    
                    if let useAoResult = result {
                        self.showPopup(title: "USE Acc Opening Status", msg: useAoResult)
                    }
                    
                    if let useAoError = error {
                        self.showPopup(title: "USE Acc Opening Status", msg: "\(useAoError.localizedDescription)")
                    }
                }
        } else {
            
            SCGateway.shared.openUsEquitiesAccount(presentingController: self)
            
        }

    }

}

extension USEAOViewController: UITextFieldDelegate {
    
    @objc func dismissKeyboard() {
        opaqueId.resignFirstResponder()
        notes.resignFirstResponder()
        
        utm_term.resignFirstResponder()
        utm_medium.resignFirstResponder()
        utm_source.resignFirstResponder()
        utm_content.resignFirstResponder()
        utm_campaign.resignFirstResponder()
        
        config_key_1.resignFirstResponder()
        config_key_2.resignFirstResponder()
        config_key_3.resignFirstResponder()
        
        config_val_1.resignFirstResponder()
        config_val_2.resignFirstResponder()
        config_val_3.resignFirstResponder()
        
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
