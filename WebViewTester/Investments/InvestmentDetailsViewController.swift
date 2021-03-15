//
//  InvestmentDetailsViewController.swift
//  WebViewTester
//
//  Created by Shivani on 19/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import UIKit
import SCGateway
import PopupDialog


class InvestmentDetailsViewController: UIViewController {
    
    enum Constants {
        static let nibName = "SmallcaseConstituentsTVCell"
        static let cellReuseId = "constituentsCellReuseId"
        static let headerNibName = "ConstiuentsHeaderView"
    }
    
    var iscid: String? {
        didSet {
            guard iscid != nil else { return }
            fetchInvestmentDetails()
            
        }
    }
    
    @IBAction func sipSetup(_ sender: Any) {
        
        guard let username = UserDefaults.standard.string(forKey: UserDefaultConstants.userId) else { return }
        let orderConfig = OrderConfig(type: nil, scid: nil, iscid: iscid, did: nil, orders: nil)
        let params = CreateTransactionBody(id: username, intent: IntentType.sipSetup.rawValue, orderConfig: orderConfig)
        
        NetworkManager.shared.getTransactionId(params: params) { [weak self] (result) in
            switch result {
            case .success(let response):
                print(response)
                guard let transactionId = response.transactionId else { return }
                self?.startSipSetupTrx(transactionId: transactionId)
                
                
            case .failure(let error):
                print(error)
                self?.showPopup(title: "Trx id error", msg: error.localizedDescription)
                //TODO: - Show Failiure popup
                
            }
        }
    }
    
    @IBAction func archiveSmt(_ sender: UIButton) {
        
        do {
            
            try SCGateway.shared.markSmallcaseArchive(iscid: iscid!) { [weak self] (response, error) in
                
                guard let response = response else {
                    if let error = error {
                        print("Archive: ERROR: \(error)")
//                        self?.showErrorAlert(err: error)
                    }
                    return
                }
             
                
                let str = String(decoding: response, as: UTF8.self)
                
                print("Archive Response: \(str)")
                self?.showPopup(title: "Smallcase Archived", msg: "\(str)")
            }
            
        }
        
    }
    
    func startSipSetupTrx(transactionId: String) {
        do {
            try  SCGateway.shared.triggerTransactionFlow(transactionId: transactionId, presentingController: self) { [weak self] (result) in
                switch result {
                case .success(let response):
                    print("HOLDING RESPONSE: \(response)")
                    self?.showPopup(title: "Sip setup Success", msg: "\(response)")
                    
                    
                case .failure(let error):
                    print(error)
                    self?.showPopup(title: "Sip setup failure", msg: "\(error.message)  \(error.rawValue)" )
                }
            }

        }
        catch let err {
            print(err)
            self.showPopup(title: "Gateway Error", msg: err.localizedDescription)
        }
    }
    
    
    
    var investmentDetails: InvestmentData? {
        didSet {
            guard let investmentDetails = investmentDetails else { return }
            DispatchQueue.main.async { [weak self] in
                
                self?.titleLabel.text = investmentDetails.investment.name
                self?.descriptionLabel.text = investmentDetails.investment.shortDescription
                self?.networthValueLabel.text = "\(investmentDetails.investment.returns?.networth ?? 0)"
            }
           
            constituents = investmentDetails.investment.currentConfig.constituents
            
            if let scid = investmentDetails.investment.scid {
                getSmallcaseImage(scid: scid)
            }
            
        }
    }
    
    
    var constituents: [Constituent]? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                   self?.constituentsTableView.reloadData()
            }
         
        }
    }
    // MARK: - UI Components
    
    @IBOutlet weak var smallcaseImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    @IBOutlet weak var networthValueLabel: UILabel!
    
    
    @IBOutlet weak var InvestedValueLabel: UILabel!
    
    
    @IBOutlet weak var returnsValueLabel: UILabel!
    
    @IBOutlet weak var constituentsTableView: UITableView! {
        didSet {
            constituentsTableView.delegate = self
            constituentsTableView.dataSource = self
            let nib = UINib(nibName: Constants.nibName, bundle: nil)
            constituentsTableView.register(nib, forCellReuseIdentifier: Constants.cellReuseId)
            
            constituentsTableView.allowsSelection = false
            constituentsTableView.separatorStyle = .singleLine
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onClickExit(_ sender: UIButton) {
    }
    
    @IBAction func onClickInvestMore(_ sender: Any) {
    }
    
    // MARK: - Utility
    
    func fetchInvestmentDetails() {
     
            SCGateway.shared.getUserInvestmentDetails(iscid: iscid!) { [weak self] (response, error) in
                
                guard let response = response else {
                    if let error = error {
                        print("INVESTMENT DETAILS: ERROR: \(error)")
//                        self?.showErrorAlert(err: error)
                    }
                    return 
                }
             
                    do {
                        let decodedInvestments = try JSONDecoder().decode(AllInvestmentsResponse.self, from: response)
                        self?.investmentDetails = decodedInvestments.data?[0]
                    }
                    catch let err {
                        print("INVESTMENT DETAILS: PARSE ERROR: \(err)")
                    }
                         
                }
    }
    
    func getSmallcaseImage(scid: String) {
        
        let urlString = "https://assets.smallcase.com/images/smallcases/200/\(scid).png"
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

    
    func showErrorAlert(err: Error) {
        let popup = PopupDialog(title: "Error ", message: err.localizedDescription )
        DispatchQueue.main.async {
            self.present(popup, animated: true, completion: nil)
        }
    }
}



extension InvestmentDetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return constituents?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellReuseId, for: indexPath) as? SmallcaseConstituentsTVCell else { fatalError()}
        cell.constiuents = constituents?[indexPath.row]
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UINib(nibName: Constants.headerNibName, bundle: nil).instantiate(withOwner: nil, options: nil)[0]  as? UIView
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

}


extension InvestmentDetailsViewController: UITableViewDelegate {
    
}
