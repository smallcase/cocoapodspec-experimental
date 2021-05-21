//
//  HoldingsViewController.swift
//  WebViewTester
//
//  Created by Dip on 29/04/20.
//  Copyright © 2020 smallcase. All rights reserved.
//

import Foundation
import UIKit
import SCGateway
import PopupDialog

class HoldingsViewController: UIViewController {
    
    var publicSmallcase: [SmallcaseHoldingDTO] = []
    var stockHoldings: [Holding] = []
    var privateSmallcaseStats: Stats? = nil
    var privateSmallcase: [SmallcaseHoldingDTO] = []
    var flag = 0
    @IBOutlet weak var holdingsTableView: UITableView!
    
    
    @IBOutlet weak var fundsLabel: UILabel!
    
    @IBAction func authoriseHoldings(_ sender: Any) {
        guard let username = UserDefaults.standard.string(forKey: UserDefaultConstants.userId) else { return }
        let params = CreateTransactionBody(id: username, intent: IntentType.authoriseHoldings.rawValue, orderConfig: nil)
        
        NetworkManager.shared.getTransactionId(params: params) { [weak self] (result) in
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
    
    
    @IBAction func fetchFunds(_ sender: Any) {
        guard let username = UserDefaults.standard.string(forKey: UserDefaultConstants.userId) else { return }
        let params = CreateTransactionBody(id: username, intent: IntentType.fetchFunds.rawValue, orderConfig: nil)
        
        NetworkManager.shared.getTransactionId(params: params) { [weak self] (result) in
            switch result {
            case .success(let response):
                print(response)
                guard let transactionId = response.transactionId else { return }
                self?.startFetchFundsTrx(transactionId: transactionId)
                
                
            case .failure(let error):
                print(error)
                self?.showPopup(title: "Trx id error", msg: error.localizedDescription)
                //TODO: - Show Failiure popup
                
            }
        }
    }
    
    
    @IBAction func updateHoldings(_ sender: Any) {
        guard let username = UserDefaults.standard.string(forKey: UserDefaultConstants.userId) else { return }
        let params = CreateTransactionBody(id: username, intent: IntentType.holding.rawValue, orderConfig: nil)
        
        NetworkManager.shared.getTransactionId(params: params) { [weak self] (result) in
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
                       self?.showPopup(msg: "\(error.message)  \(error.rawValue)" )
                   }
               }

           }
           catch let err {
               print(err)
               self.showPopup(title: "Gateway Error", msg: err.localizedDescription)
           }
       }
    
    func startFetchFundsTrx(transactionId: String) {
             do {
                 try  SCGateway.shared.triggerTransactionFlow(transactionId: transactionId, presentingController: self) { [weak self] (result) in
                     switch result {
                     case .success(let response):
                         print("HOLDING RESPONSE: \(response)")
                         self?.showPopup(title: "Holdings Response", msg: "\(response)")
                        
                         switch response {
                         case .fetchFunds( _,let fund, _):
                            self?.fundsLabel.text = String(fund)
                         default:
                            return
                        }
                         
                         
                     case .failure(let error):
                         print(error)
                         self?.showPopup(msg: "\(error.message)  \(error.rawValue)" )
                     }
                 }

             }
             catch let err {
                 print(err)
                 self.showPopup(title: "Gateway Error", msg: err.localizedDescription)
             }
         }
    
    func showPopup(title: String = "Error" , msg: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
               let popup = PopupDialog(title: title, message: msg)
               self?.present(popup, animated: true, completion: nil)
           }
       }
    
    @IBAction func showUpdatedHoldings(_ sender: Any) {
        fetchHoldings()
    }
    
    func fetchHoldings()  {
        guard let username = UserDefaults.standard.string(forKey: UserDefaultConstants.userId) else { return }
        NetworkManager.shared.getHoldings(username: username){ [weak self] (result) in
            switch result {
            case .success(let response):
                
                DispatchQueue.main.async { // Correct
                    self?.publicSmallcase.removeAll()
                    self?.publicSmallcase.append(contentsOf: response.data.data.smallcases.public)
                    
//                    if(response.data.data.smallcases.private is Stats) {
//                        self?.privateSmallcaseStats = response.data.data.smallcases.private
//                    }
                    self?.privateSmallcase = response.data.data.smallcases.private
                    self?.flag = 0
                    self?.stockHoldings.removeAll()
                    self?.stockHoldings.append(contentsOf: response.data.data.securities.holdings)
                    self?.holdingsTableView.reloadData()
                }
               
                //self?.showPopup(msg: "\(response)")
                
                
                case .failure(_):
//               self?.showPopup(msg: "\(error)")
                
                NetworkManager.shared.getHoldings2(username: username) { [weak self] (result) in
                    
                    switch result {
                        
                        case .success(let response):
                            DispatchQueue.main.async {
                                self?.publicSmallcase.removeAll()
                                self?.publicSmallcase.append(contentsOf: response.data.data.smallcases.public)
                                self?.privateSmallcaseStats = response.data.data.smallcases.private.stats
                                self?.flag = 1
                                self?.stockHoldings.removeAll()
                                self?.stockHoldings.append(contentsOf: response.data.data.securities.holdings)
                                
                                self?.holdingsTableView.reloadData()
                            }
                        
                        case .failure(let error):
                            self?.showPopup(msg: "\(error)")
                    }
                }
                
            }
        }
    }
    override func viewDidLoad() {
        holdingsTableView.dataSource = self
        holdingsTableView.delegate = self
        holdingsTableView.register(UINib(nibName: "PublicSmallcaseCell", bundle: nil) , forCellReuseIdentifier: "public_smallcase_cell")
        holdingsTableView.register(UINib(nibName: "PrivateSmallcaseCell", bundle: nil) , forCellReuseIdentifier: "private_smallcase_cell")
        holdingsTableView.register(UINib(nibName: "StocksCell", bundle: nil) , forCellReuseIdentifier: "stock_cell")
    }
}

extension HoldingsViewController :UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Public Smallcases"
        case 1:
            return "Private Smallcases"
        default:
            return "Stocks"
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return publicSmallcase.count
        case 1:
            if(self.flag == 0) {
                return privateSmallcase.count
            } else {
                return 1
            }
            
        default:
            return stockHoldings.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let simpleTableIdentifier:String = "public_smallcase_cell"
            let cell:PublicSmallcaseCell! = tableView.dequeueReusableCell(withIdentifier: simpleTableIdentifier) as? PublicSmallcaseCell
            /**if (cell == nil) {
                let nib:[CustomCell] = Bundle.main.loadNibNamed("CustomCell", owner: self, options: nil) as!
                [CustomCell]
                cell = nib[0]
            }*/
            let imgUrl:String! = publicSmallcase[indexPath.row].imageUrl
            if  imgUrl != nil {
                cell.publicImage.load(url: URL(string: imgUrl)!)
            }
            cell.titleLabel.text = "Name: \(publicSmallcase[indexPath.row].name ?? "NA")"
            cell.detailsLabel.text = "Des: \(publicSmallcase[indexPath.row].shortDescription ?? "NA")"
            cell.priceLabel.text = "Price: \(publicSmallcase[indexPath.row].stats?.currentValue ?? 0.00)"
            
            return cell
            
        } else if (indexPath.section == 2) {
           let simpleTableIdentifier:String = "stock_cell"
            let cell:StocksCell! = tableView.dequeueReusableCell(withIdentifier: simpleTableIdentifier) as? StocksCell
           /** if (cell == nil) {
                let nib:[StocksCell] = Bundle.main.loadNibNamed("StocksCell", owner: self, options: nil) as!
                [StocksCell]
                cell = nib
            }*/
           // print(cell.stockTitleLabel)
            print(stockHoldings)
            print(indexPath.row)
            cell.titleLabel.text = "Name: \(stockHoldings[indexPath.row].name)"
            cell.sharesLabel.text = "Shares: \(stockHoldings[indexPath.row].shares)"
            cell.averagePriceLabel.text = "Price: \(stockHoldings[indexPath.row].averagePrice)"
            
            return cell
        } else {
            let simpleTableIdentifier:String = "private_smallcase_cell"
            let cell:PrivateSmallcaseCell! = tableView.dequeueReusableCell(withIdentifier: simpleTableIdentifier) as? PrivateSmallcaseCell
             /**if (cell == nil) {
                 let nib:[CustomCell] = Bundle.main.loadNibNamed("CustomCell", owner: self, options: nil) as!
                 [CustomCell]
                 cell = nib[1]
             }*/
            
            
            if(self.flag == 0) {
                
                cell.nameLabel.text = "Name: \(privateSmallcase[indexPath.row].name ?? "")"
                
                if let scValue = privateSmallcase[indexPath.row].stats?.currentValue {
                    cell.valueLabel.text = "Value: \(scValue)"
                } else {
                    cell.valueLabel.text = "Value: NA"
                }
                
                
                let imgUrl:String! = privateSmallcase[indexPath.row].imageUrl
                if  imgUrl != nil {
                    cell.privateScImage.load(url: URL(string: imgUrl)!)
                }
                
            } else {
                cell.nameLabel.text = "Total returns: \(privateSmallcaseStats?.totalReturns)"
                cell.valueLabel.text = "Current Value: \(privateSmallcaseStats?.currentValue)"
//                cell.privateScImage.image = UIImage(named: "gatewaydemoo")
            }

             return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section==0 {
            return 94.0
        }else if indexPath.section==1
        {
            return 59.0
    }else
        {
            return 86
        }
    }
    
    
}
