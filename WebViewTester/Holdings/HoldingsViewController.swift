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
    var userStockHoldings: [FetchHoldingsSecurities] = []
    var privateSmallcaseStats: Stats? = nil
    var privateSmallcase: [SmallcaseHoldingDTO] = []
    var mutualFunds: [MutualFundsHoldings] = []
    
    //Flag = 0 => First Party Gateway
    //Flag = 1 => Third Party Gateway
    var flag = 0
    
    var isThirdPartyGateway = true
    
    @IBOutlet weak var holdingsTableView: UITableView!
    
    @IBAction func authoriseHoldings(_ sender: Any) {
        guard let username = UserDefaults.standard.string(forKey: UserDefaultConstants.userId) else { return }
        let params = CreateTransactionBody(id: username, intent: IntentType.authoriseHoldings.rawValue, orderConfig: nil)
        
        createTransactionId(params: params)
    }
    
    @IBAction func fetchFunds(_ sender: Any) {
        guard let username = UserDefaults.standard.string(forKey: UserDefaultConstants.userId) else { return }
        let params = CreateTransactionBody(id: username, intent: IntentType.fetchFunds.rawValue, orderConfig: nil)
        
        createTransactionId(params: params)
    }
    
    @IBOutlet weak var fundsLabel: UILabel!
    
    @IBAction func updateHoldings(_ sender: Any) {
        guard let username = UserDefaults.standard.string(forKey: UserDefaultConstants.userId) else { return }
        let params = CreateTransactionBody(id: username, intent: IntentType.holding.rawValue, orderConfig: nil)
        
        createTransactionId(params: params)
    }
    
    @IBAction func showUpdatedHoldings(_ sender: Any) {
        fetchHoldings()
    }
    
    @IBOutlet weak var holdingsV2Switch: UISwitch!
    
    @IBOutlet weak var holdingsMfSwitch: UISwitch!
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        holdingsTableView.dataSource = self
        holdingsTableView.delegate = self
        holdingsTableView.register(UINib(nibName: "PublicSmallcaseCell", bundle: nil) , forCellReuseIdentifier: "public_smallcase_cell")
        holdingsTableView.register(UINib(nibName: "PrivateSmallcaseCell", bundle: nil) , forCellReuseIdentifier: "private_smallcase_cell")
        holdingsTableView.register(UINib(nibName: "StocksCell", bundle: nil) , forCellReuseIdentifier: "stock_cell")
        holdingsTableView.register(UINib(nibName: "UserStockHoldingCellTableViewCell", bundle: nil) , forCellReuseIdentifier: "user_stock_cell")
        holdingsTableView.register(UINib(nibName: "MutualFundHoldingCell", bundle: nil), forCellReuseIdentifier: "mutual_fund_holdings_cell")
    }
    
    //MARK: Create TxnID
    private func createTransactionId(params: CreateTransactionBody) {
        
        NetworkManager.shared.getTransactionId(params: params) { [weak self] (result) in
            switch result {
                case .success(let response):
                    print(response)
                    guard let transactionId = response.transactionId else { return }
                    self?.triggerHoldingsTransaction(transactionId: transactionId)
                    
                    
                case .failure(let error):
                    print(error)
                    self?.showPopup(title: "Error creating TxnId", msg: error.localizedDescription)
                    
            }
        }
        
    }
    
    //MARK: Trigger Transaction
    func triggerHoldingsTransaction(transactionId: String) {
           do {
               try  SCGateway.shared.triggerTransactionFlow(transactionId: transactionId, presentingController: self) { [weak self] (result) in
                    switch result {
                       case .success(let response):
                           print("HOLDING RESPONSE: \(response)")
                           self?.showPopup(title: "Holdings Response", msg: "\(response)")
                       
                       case .failure(let error):
                           print(error)
                            self?.showPopup(title: "Holdings Error", msg: self?.convertErrorToJsonString(error: error) ?? "error converting transaction error to JSON")
                   }
               }

           }
           catch let err {
               print(err)
               self.showPopup(title: "Gateway Error", msg: err.localizedDescription)
           }
       }
    
    //MARK: Fetch User Holdings
    func fetchHoldings() {
        
        guard let username = UserDefaults.standard.string(forKey: UserDefaultConstants.userId) else { return }
        
        if holdingsV2Switch.isOn {
            
            NetworkManager.shared.fetchUserHoldings(
                username: username,
                mutualFunds: self.holdingsMfSwitch.isOn
            ) { [weak self] (result) in
                
                switch result {
                        
                    case .success(let response):
                        self?.updateHoldingsTable(response: response)
                    
                    case .failure(let error):
                        self?.showPopup(title: "Error", msg: "\(error)")
                }
            }
            
        } else {
            
            NetworkManager.shared.getHoldings(username: username){ [weak self] (result) in
                switch result {
                    case .success(let response):
                        
                        DispatchQueue.main.async { // Correct
                            self?.publicSmallcase.removeAll()
                            self?.publicSmallcase.append(contentsOf: response.data.data.smallcases.public)
                            
                            //                    if(response.data.data.smallcases.private is Stats) {
                            //                        self?.privateSmallcaseStats = response.data.data.smallcases.private
                            //                    }
//                            self?.privateSmallcase = response.data.data.smallcases.private
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
                                    self?.showPopup(title: "Error", msg: "\(error)")
                            }
                        }
                        
                }
            }
            
        }
        
    }
    
    //MARK: Update Holdings table
    func updateHoldingsTable(response: FetchHoldingsResponse) {
        
        DispatchQueue.main.async {
            
            self.publicSmallcase.removeAll()
            self.publicSmallcase.append(contentsOf: response.data.data.smallcases.public)
            
            if let privateSmallcaseHoldings = response.data.data.smallcases.private.investments {
                self.privateSmallcase = privateSmallcaseHoldings
                self.flag = 0
            } else {
                self.flag = 1
                self.privateSmallcaseStats = response.data.data.smallcases.private.stats
            }
            
            self.userStockHoldings.removeAll()
            self.userStockHoldings.append(contentsOf: response.data.data.securities)
            
            if let mfHoldings = response.data.data.mutualFunds?.holdings {
                self.mutualFunds.removeAll()
                self.mutualFunds.append(contentsOf: mfHoldings)
            }
            
            self.holdingsTableView.reloadData()
        }
    }
    
}

extension HoldingsViewController :UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Public Smallcases"
        case 1:
            return "Private Smallcases"
        case 2:
            return "Stocks"
        default:
            return "Mutual Funds"
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
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
        case 2:
            if self.holdingsV2Switch.isOn {
                return userStockHoldings.count
            } else {
                return stockHoldings.count
            }
        
        default:
            return self.mutualFunds.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
            
            case 0:
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
            
            case 1:
                let simpleTableIdentifier:String = "private_smallcase_cell"
                let cell:PrivateSmallcaseCell! = tableView.dequeueReusableCell(withIdentifier: simpleTableIdentifier) as? PrivateSmallcaseCell
                /**if (cell == nil) {
                 let nib:[CustomCell] = Bundle.main.loadNibNamed("CustomCell", owner: self, options: nil) as!
                 [CustomCell]
                 cell = nib[1]
                 }*/
                
                
                if(self.flag == 0) {
                    
                    cell.nameLabel.isHidden = false
                    cell.nameLabel.text = "Name: \(privateSmallcase[indexPath.row].name ?? "")"
                    
                    if let scValue = privateSmallcase[indexPath.row].stats?.currentValue {
                        cell.valueLabel.text = "Value: \(scValue)"
                    } else {
                        cell.valueLabel.text = "Value: NA"
                    }
                    
                    if let totalReturns = privateSmallcase[indexPath.row].stats?.totalReturns {
                        cell.totalReturns.text = "Total Returns: \(totalReturns)"
                    } else {
                        cell.totalReturns.text = "Total Returns: NA"
                    }
                    
                    let imgUrl:String! = privateSmallcase[indexPath.row].imageUrl
                    if  imgUrl != nil {
                        cell.privateScImage.load(url: URL(string: imgUrl)!)
                    }
                    
                } else {
                    
                    cell.nameLabel.isHidden = true
                    if let totalReturns = privateSmallcaseStats?.totalReturns, let currentValue = privateSmallcaseStats?.currentValue {
                        cell.totalReturns.text = "Total returns: \(String(describing: totalReturns))"
                        cell.valueLabel.text = "Current Value: \(String(describing: currentValue))"
                    }
                    
                }
                
                return cell
                
            case 2:
                if self.holdingsV2Switch.isOn {
                    
                    let userStockIdentifier: String = "user_stock_cell"
                    
                    let stockCell: UserStockHoldingCellTableViewCell = tableView.dequeueReusableCell(withIdentifier: userStockIdentifier) as! UserStockHoldingCellTableViewCell
                    
                    stockCell.userStockName.text = userStockHoldings[indexPath.row].name
                    stockCell.userStockISIN.text = userStockHoldings[indexPath.row].isin
                    stockCell.userStockTransactableQty.text = userStockHoldings[indexPath.row].transactableQuantity?.description
                    stockCell.userStockSmallcaseQty.text = userStockHoldings[indexPath.row].smallcaseQuantity?.description
                    
                    stockCell.userStockNseTicker.text = userStockHoldings[indexPath.row].nseTicker
                    stockCell.nsePositionsShares.text = userStockHoldings[indexPath.row].positions?.nse?.quantity?.description ?? "0"
                    stockCell.nsePositionsAvgPrice.text = userStockHoldings[indexPath.row].positions?.nse?.averagePrice?.description ?? "0"
                    
                    stockCell.bseTicker.text = userStockHoldings[indexPath.row].bseTicker
                    stockCell.bsePositionsShares.text = userStockHoldings[indexPath.row].positions?.bse?.quantity?.description ?? "0"
                    stockCell.bsePositionsAvgPrice.text = userStockHoldings[indexPath.row].positions?.bse?.quantity?.description ?? "0"
                    
                    stockCell.holdingsShares.text = userStockHoldings[indexPath.row].holdings?.quantity?.description
                    stockCell.holdingsAvgPrice.text = userStockHoldings[indexPath.row].holdings?.averagePrice?.description
                    
                    return stockCell
                    
                } else {
                    
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
                    cell.averagePriceLabel.text = "Price: \(String(describing: stockHoldings[indexPath.row].averagePrice))"
                    
                    return cell
                    
                }
            
            default:
                
                let mutualFundIdentifier = "mutual_fund_holdings_cell"
                
                let mfCell: MutualFundHoldingCell = tableView.dequeueReusableCell(withIdentifier: mutualFundIdentifier) as! MutualFundHoldingCell
                
                mfCell.mfFolio.text = mutualFunds[indexPath.row].folio
                mfCell.mfFund.text = mutualFunds[indexPath.row].fund
                mfCell.mfIsin.text = mutualFunds[indexPath.row].isin
                mfCell.mfPnl.text = mutualFunds[indexPath.row].pnl.description
                mfCell.mfAvgPrice.text = mutualFunds[indexPath.row].averagePrice.description
                mfCell.mfQuantity.text = mutualFunds[indexPath.row].quantity.description
                mfCell.mfLastPrice.text = mutualFunds[indexPath.row].lastPrice.description
                mfCell.mfLastPriceDate.text = mutualFunds[indexPath.row].lastPriceDate
                
                return mfCell
                       
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
            case 0:
                return 94.0
            case 1:
                return 150.0
            case 2:
                if holdingsV2Switch.isOn {
                    return 400.0
                } else {
                    return 150.0
                }
                
            default:
                return 255.0
        }
        
    }

}
