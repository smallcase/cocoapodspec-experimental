//
//  SmallcaseListViewController.swift
//  WebViewTester
//
//  Created by Shivani on 15/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import UIKit
import SCGateway
//import PopupDialog


class SmallcaseListViewController: UITableViewController {
    
    var smallcases: [Smallcase]? = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
            
        }
    }
    
    enum Constant {
        
        static let nibName           = "SmallcaseTableViewCell"
        static let cellReuseId       = "SmallcaseListCellReuseId"
        static let smallcaseSegueId  = "showSmallcaseProfile"
        static let investmentsListSegueId = "showInvestedSmallcases"
        
    }
    
    @IBAction func triggeringHoldings(_ sender: Any) {
        
        guard let username = UserDefaults.standard.string(forKey: UserDefaultConstants.userId) else { return }
        let params = CreateTransactionBody(id: username, intent: IntentType.holding.rawValue, orderConfig: nil)
        
        SmartinvestingApi.shared.getTransactionId(params: params) { [weak self] (result) in
            switch result {
            case .success(let response):
                print(response)
                guard let transactionId = response.transactionId else { return }
                self?.startHoldingTrx(transactionId: transactionId)
                
                
            case .failure(let error):
                print(error)
                self?.showPopup(title: "Trx id error", msg: error.localizedDescription)
                //TODO: - Show Failiure popup
                
            }
        }
        
        
    }
    
    
    
    func startHoldingTrx(transactionId: String) {
        do {
            try  SCGateway.shared.triggerTransactionFlow(transactionId: transactionId, presentingController: self) { [weak self] (result) in
                switch result {
                case .success(let response):
                    print("HOLDING RESPONSE: \(response)")
                    self?.showPopup(title: "Holdings Response", msg: "\(response)")
                    
                    
                case .failure(let error):
                    print(error)
                        self?.showPopup(title: "Holdings ERROR:", msg: self?.convertErrorToJsonString(error: error) ?? "error converting transaction error to JSON")
//                    self?.showPopup(msg: error.message )
                        
                }
            }

        }
        catch let err {
            print(err)
            self.showPopup(title: "Gateway Error", msg: err.localizedDescription)
        }
    }
    
    func showPopup(title: String = "Error" , msg: String) {
        DispatchQueue.main.async { [weak self] in
            
//            let popup = PopupDialog(title: title, message: msg)
//            self?.present(popup, animated: true, completion: nil)
        }
    }
    
    //MARK:- View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: Constant.nibName, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: Constant.cellReuseId)
        tableView.delegate = self
        tableView.dataSource = self
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getSmallcases()
    }
    
    func getSmallcases() {
        SCGateway.shared.getSmallcases(params: nil) { [weak self] (data, error) in
            
            
            guard let response = data else {
                
                print(error ?? "No error object")
                return
                
            }
         
                do {
                    let decodedData = try JSONDecoder().decode(SmallcaseListResponse.self, from: response)
                    self?.smallcases = decodedData.data?.smallcases
                }
                catch let err {
                    print(err)
                }

        }
    }
    
    
}

//MARK:- UITableView DataSource
extension SmallcaseListViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return smallcases?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.cellReuseId, for: indexPath) as? SmallcaseTableViewCell else { fatalError("Could not load tv cell")}
        cell.selectionStyle = .none
        cell.smallcaseName = smallcases?[indexPath.item].info.name
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? SmallcaseProfileViewController else { return}
        
        let scid = smallcases![tableView.indexPathForSelectedRow!.item].scid
         vc.scid = scid
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       let header = SmallcaseListHeaderView()
        header.backgroundColor = .orange
        header.delegate = self
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}



extension SmallcaseListViewController: SmallcaseListHeaderDelegate {
    func showInvestments() {
        performSegue(withIdentifier: Constant.investmentsListSegueId, sender: self)
    }
    
    
}
//MARK:- UITableVIew Delegate
extension SmallcaseListViewController {
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Constant.smallcaseSegueId, sender: self)
    }
}
