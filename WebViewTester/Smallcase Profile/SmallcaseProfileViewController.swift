//
//  SmallcaseProfileViewController.swift
//  WebViewTester
//
//  Created by Shivani on 15/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import UIKit
import SCGateway

class SmallcaseProfileViewController: UIViewController {
    
    enum Constant {
        static let cellNibName = "SmallcaseConstituentsTVCell"
        static let constituentsCellReuseId = "constituentsCellReuseId"
        static let newsSegueId = "showSmallcaseNews"
        static let historicalSegue = "showHistorical"
    }
    
    var scid: String? {
        didSet {
            getSmallcaseProfile()
            getSmallcaseImage()
        }
    }
    
    var smallcase: Smallcase? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.smallcaseNameLabel.text = self?.smallcase?.info.name
                self?.smallcaseDescriptionLabel.text = self?.smallcase?.info.shortDescription
                self?.minAmountLabel.text = "\(self?.smallcase?.stats?.minInvestAmount ?? 0)"
                self?.constituentsTableView.reloadData()
                
            }
            
        }
    }
    
    @IBOutlet weak var smallcaseImageView: UIImageView!
    
    @IBOutlet weak var smallcaseDescriptionLabel: UILabel!
    
    @IBOutlet weak var smallcaseNameLabel: UILabel!
    
    @IBOutlet weak var minAmountLabel: UILabel!
    
    
    @IBOutlet weak var constituentsTableView: UITableView! {
        didSet {
            let nib = UINib(nibName: Constant.cellNibName, bundle: nil)
            constituentsTableView.register(nib, forCellReuseIdentifier: Constant.constituentsCellReuseId)
            constituentsTableView.delegate = self
            constituentsTableView.dataSource = self
            constituentsTableView.isUserInteractionEnabled = false
        }
    }
    
    
    @IBAction func onClickSubscribe(_ sender: Any) {
        
        guard let scid = scid, let userId = UserDefaults.standard.string(forKey: UserDefaultConstants.userId) else { return }
        
        let subscriptionConfig = SubscriptionConfig(scid: scid, iscid: nil)
        
        let subcriptionBody = CreateSubscriptionBody(id: userId, intent: IntentType.subscription.rawValue, config: subscriptionConfig)
        
        NetworkManager.shared.getSubscriptionTransactionId(params: subcriptionBody) { [weak self] (result) in
            
            switch result {
                case .success(let response):
                    print(response)
                    guard let transactionId = response.transactionId else { return }
                    self?.triggerTransaction(trxId: transactionId)
                    
                case .failure(let error):
                    print(error)
            }
            
        }
    }
    
    @IBAction func onClickBuy(_ sender: UIButton) {
        guard let scid = scid, let userId = UserDefaults.standard.string(forKey: UserDefaultConstants.userId) else { return }
        let orderConfig = OrderConfig(type: OrderType.buy.rawValue, scid: scid, iscid: nil, did: nil, orders: nil)
        let transactionBody = CreateTransactionBody(id: userId, intent: IntentType.transaction.rawValue, orderConfig: orderConfig)
        
        NetworkManager.shared.getTransactionId(params: transactionBody) {[weak self] (result) in
            switch result {
            case .success(let response):
                print(response)
                guard let transactionId = response.transactionId else { return }
                self?.triggerTransaction(trxId: transactionId)
                
            case .failure(let error):
                print(error)
            }
        }
        
        
    }
    
    @IBAction func onClickNews(_ sender: UIButton) {
        performSegue(withIdentifier: Constant.newsSegueId, sender: self)
    }
    
    
    @IBAction func onClickHistorical(_ sender: UIButton) {
        performSegue(withIdentifier: Constant.historicalSegue, sender: self)
    }
    
    
    
    func triggerTransaction(trxId: String) {
        do {
            try? SCGateway.shared.triggerTransactionFlow(transactionId: trxId, presentingController: self) { (result) in
                switch result {
                case.success(let response):
                    self.showPopup(title: "Success", msg: "\(response)")
                    print(response)
                    
                case .failure(let error):
//                    self.showPopup(title: "SMT TRANSACTION: ERROR:", msg: "\(error.message) \(error.rawValue)")
                        self.showPopup(title: "SMT TRANSACTION: ERROR:", msg: self.convertErrorToJsonString(error: error) ?? "error converting transaction error to JSON")
                    print(error)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    
    func getSmallcaseProfile() {
        
        SCGateway.shared.getSmallcaseProfile(scid: scid!) { [weak self] data, error in
            
            guard let response = data else {
                print(error ?? "")
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(SmallcaseProfileResponse.self, from: response)
                self?.smallcase = decodedData.data
            }
            catch let error {
                print(error)
            }
            
        }
    }
    
    
    func getSmallcaseImage() {
        
        let urlString = "https://assets.smallcase.com/images/smallcases/200/\(scid!).png"
        guard let url = URL(string: urlString) else { return}
        do {
            let data = try Data(contentsOf: url)
            DispatchQueue.main.async { [weak self] in
                self?.smallcaseImageView.image = UIImage(data: data)
            }
        }
        catch let err {
            print(err)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  let sender = segue.destination as? NewsViewController {
            sender.scid = scid
            return
        }
            
        else if let sender = segue.destination as? HistoricalViewController {
            sender.benchmarkId = smallcase?.benchmark.id
            sender.scid = scid
        }
        
    }
}


extension SmallcaseProfileViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return smallcase?.constituents?.count ?? 0
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.constituentsCellReuseId, for: indexPath) as? SmallcaseConstituentsTVCell else { fatalError() }
        cell.constiuents = smallcase?.constituents?[indexPath.item]
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UINib(nibName: "ConstiuentsHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0]  as? UIView
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
}

extension SmallcaseProfileViewController: UITableViewDelegate {
    
}
