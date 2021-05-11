//
//  CreateViewController.swift
//  WebViewTester
//
//  Created by Shivani on 12/06/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import UIKit
import SCGateway

class CreateViewController: UIViewController {
    
    let reuseId = "CellReuseId"
    let searchReuseId = "SearchReuseId"
    let displayNibName = "CreateTableViewCell"
    let searchNibName = "SearchCell"
    var urlString = ""
    
    var selectedStock: Stock? = nil
    
    var searchResults: [Stock] = []
    let queryService = QueryService()
    var transactions: [Order] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                
                self?.createTableView.reloadData()
            }
        }
    }
    
    
    lazy var tapRecognizer: UITapGestureRecognizer = {
        var recognizer = UITapGestureRecognizer(target:self, action: #selector(dismissKeyboard))
        return recognizer
    }()
    
    
    @IBOutlet weak var quantityTextField: UITextField! {
        didSet {
            quantityTextField.delegate = self
        }
    }
    
    @IBOutlet weak var transationTypeSegment: UISegmentedControl!
    
    @IBOutlet weak var createTableView: UITableView! {
        didSet {
            
            createTableView.delegate = self
            createTableView.dataSource = self
            
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }
    
    @IBOutlet weak var searchTableView: UITableView! {
        didSet {
            searchTableView.delegate = self
            searchTableView.dataSource = self
            searchTableView.isHidden = true
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: displayNibName, bundle: nil)
        let searchCell = UINib(nibName: searchNibName, bundle: nil)
        
        createTableView.register(nib, forCellReuseIdentifier: reuseId)
        searchTableView.register(searchCell, forCellReuseIdentifier: searchReuseId)
        
        // Do any additional setup after loading the view.
    }
    
    
    //MARK:- Actions
    @IBAction func onClickPlaceOrder(_ sender: UIButton) {
        
        
        guard let userId = UserDefaults.standard.string(forKey: UserDefaultConstants.userId) else {
            showPopup(title: "Error", msg: "User Setup Not done")
            return
            
        }
        
        guard !transactions.isEmpty else {
            showPopup(title: "ERROR: Empty", msg: "Add Items to place order")
            return
            
        }
        
        let orderConfig = OrderConfig(type: OrderType.securities.rawValue, scid: nil, iscid: nil, did: nil, orders: transactions)
        
        let transactionBody = CreateTransactionBody(id: userId, intent: IntentType.transaction.rawValue, orderConfig: orderConfig)
        
        NetworkManager.shared.getTransactionId(
        params: transactionBody) { [weak self] (result) in
            
            switch result {
            case .success(let response):
                guard let trxId = response.transactionId else {
                    self?.showPopup(title: "GET TRANSACTION: Null Id:", msg: "\(response)")
                    return }
                self?.placeTransaction(transactionId: trxId)
                
            case .failure(let error):
                print(error)
                print("GET TRANSACTION: ERROR: \(error)")
                self?.showPopup(title: "GET TRANSACTION: ERROR:", msg: "\(error)")
            }
            
        }
        
    }
    
    
    @IBAction func onClickReset(_ sender: UIBarButtonItem) {
        
        transactions = []
        selectedStock = nil
        searchBar.text = nil
    }
  
    func placeTransaction(transactionId: String) {
        
        do {
            
            let utmParams = [
                "utm_source": "summer-mailer" ,
                "utm_campaign":"summer-sale",
                "utm_medium":"email",
                "utm_term":"paid",
                "utm_content":"toplink"
            ]
            try  SCGateway.shared.triggerTransactionFlow(transactionId: transactionId, presentingController: self, utmParams: utmParams, completion: { [weak self] (result) in
                switch result {
                case .success(let response):
                    print("SST TRANSACTION: RESPONSE:  \(response)")
                    self?.showPopup(title: "SST TRANSACTION: RESPONSE: ", msg: "\(response)")
                    
                    
                case .failure(let error):
                    print("SST TRANSACTION: ERROR: \(error)")
                    self?.showPopup(title: "SST TRANSACTION: ERROR:", msg: "\(error.message) \(error.rawValue)")
                    
                }
            })
        }
        catch let err {
            print(err)
        }
    }
    
    @IBAction func onClickAdd(_ sender: UIButton) {
        if let stock = selectedStock {
            let quantity = Int(quantityTextField.text ?? "")
            let transactionType = TransactionType(rawValue: transationTypeSegment.selectedSegmentIndex)?.toString
       
            let transactionObj = Order(ticker: stock.ticker ?? "", type: transactionType, quantity:quantity)
            transactions.append(transactionObj)
            
        }
    }
}

extension CreateViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.createTableView {
            return transactions.count
        }
        else if tableView == self.searchTableView {
            return searchResults.count
        } 
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == createTableView, let cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath) as? CreateTableViewCell {
            cell.tickerLabel.text = transactions[indexPath.item].ticker
            cell.quantityLabel.text = "\(transactions[indexPath.item].quantity )"
            cell.transactionTypeLabel.text = transactions[indexPath.item].type
            cell.selectionStyle = .none
            return cell
        }
        
        if tableView == searchTableView, let cell = tableView.dequeueReusableCell(withIdentifier: searchReuseId, for: indexPath) as? SearchCell {
            cell.nameLabel.text = searchResults[indexPath.item].name
            cell.tickerLabel.text = searchResults[indexPath.item].ticker
            return cell
        }
        
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView == searchTableView) {
            searchBar.text = searchResults[indexPath.item].ticker
            selectedStock = searchResults[indexPath.item]
            tableView.isHidden = true
        }
    }
}


extension CreateViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        quantityTextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        view.addGestureRecognizer(tapRecognizer)
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        view.removeGestureRecognizer(tapRecognizer)
    }
    
}


