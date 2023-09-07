//
//  MFHoldingsViewController.swift
//  WebViewTester
//
//  Created by Indrajit Roy on 27/09/22.
//  Copyright © 2022 smallcase. All rights reserved.
//

import UIKit
import SCGateway

class MFHoldingsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet var startDate: UITextField!
    @IBOutlet var notesInutField: UITextField!
    @IBOutlet var txnId: UITextField!
    
    @IBAction func onTriggerMfTransactionTapped() {
        importMFHoldings(transactionId: txnId.text ?? "")
    }
    
    @IBAction func onPostbackSearchTap() {
        getMfHoldings(transactionId: txnId.text ?? "")
    }
    
    @IBAction func onMFImportTapped() {
        let fromDate = startDate.text?.isEmpty == false ? startDate.text : nil
        let notes = notesInutField.text?.isEmpty == false ? notesInutField.text : nil
        let params = CreateTransactionBody(id: "", intent: IntentType.MF_HOLDINGS_IMPORT.rawValue,notes: notes, orderConfig: nil, assetConfig: AssetConfig(fromDate: fromDate))
        createTransactionId(params: params) { txnId in
            guard let id = txnId else {
                self.showPopup(title: "Error creating TxnId", msg: "Something went wrong")
                return
            }
            self.importMFHoldings(transactionId: id)
        }
    }
    
    func importMFHoldings(transactionId:String) {
        do {
            try  SCGateway.shared.triggerMfTransaction(presentingController: self, transactionId: transactionId, completion: { [weak self] (result) in
                switch result {
                case .success(let response):
                    print("HOLDING RESPONSE: \(response)")
                    self?.showPopup(title: "Holdings Response", msg: "\(response)") {
                        print("SUCCESS POPUP COMPLETED")
                        self?.getMfHoldings(transactionId: transactionId)
                    }
                    
                case .failure(let error):
                    print(error)
                    self?.showPopup(title: "Holdings Error", msg: self?.convertErrorToJsonString(error: error) ?? "error converting transaction error to JSON")
                }
            })
        }
        catch let err {
            print(err)
            self.showPopup(title: "Gateway Error", msg: err.localizedDescription)
        }
    }
    
    func getMfHoldings(transactionId: String) -> Void {
        NetworkManager.shared.getPostbackResponse(transactionId: transactionId) { result in
            switch result {
            case .success(let response):
                print("MF HOLDING RESPONSE: \(response)")
                self.showPopup(title: "Holdings Response", msg: "\(response)")
                
            case .failure(let error):
                print(error)
                self.showPopup(title: "Holdings Error", msg: "\(error)")
            }
        }
    }
}

private func createTransactionId(params: CreateTransactionBody, completion: @escaping (String?) -> Void) {
    
    NetworkManager.shared.getTransactionId(params: params) { (result) in
        switch result {
        case .success(let response):
            print(response)
            guard let transactionId = response.transactionId else { return }
            completion(transactionId)
            
            
        case .failure(let error):
            print(error)
            
        }
    }
    
}
