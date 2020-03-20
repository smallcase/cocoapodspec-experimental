//
//  InvestmentsListViewController.swift
//  WebViewTester
//
//  Created by Shivani on 17/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import UIKit
import SCGateway



class InvestmentsListViewController: UIViewController {
    
    enum Constants {
        
        static let cellReuseId = "SmallcaseListCellReuseId"
        static let cellNibName = "SmallcaseTableViewCell"
        static let investmentDetailsSegueId = "showInvestmentDetails"
    }
    
    enum SelectionType: Int {
        case investments = 0
        case exited = 1
    }
    
    var selectionType: SelectionType = .investments {
        didSet {
            if selectionType == oldValue { return }
            
            switch selectionType {
            case .investments:
                getInvestedSmallcases()
            case .exited:
                getExitedSmallcases()
            }
            
        }
    }
    
    var exitedSmallcases: [ExitedSmallcase] = [] {
        didSet {
            if selectionType == .exited {
                DispatchQueue.main.async { [weak self] in
                    self?.tableView.reloadData()
                    LoadingOverlay.shared.hideLoader()
                }
                
            }
        }
    }
    
    var investedSmallcases: [InvestmentData] = [] {
        didSet {
            
            if selectionType == .investments {
                DispatchQueue.main.async { [weak self] in
                    self?.tableView.reloadData()
                    LoadingOverlay.shared.hideLoader()
                }
            }
        }
    }
    
    // MARK: - UI Components
    
    @IBOutlet weak var segmentController: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            
            let nib = UINib(nibName: Constants.cellNibName , bundle: nil)
            tableView.register(nib, forCellReuseIdentifier: Constants.cellReuseId)
            tableView.delegate = self
            tableView.dataSource = self
            
            
        }
    }
    
    
    // MARK : - Actions
    @IBAction func segmentValueDidChange(_ sender: UISegmentedControl) {
        
        selectionType = SelectionType(rawValue: sender.selectedSegmentIndex)!
        tableView.reloadData()
    }
    
    
    func getInvestedSmallcases() {
        
        SCGateway.shared.getUserInvestments(iscids: nil) { [weak self] (data, error) in
            
            guard let response = data  else {
                print("INVESTMENTS: ERROR: \(error)")
                return
            }
            
            do {
                let investments = try JSONDecoder().decode(AllInvestmentsResponse.self,
                                                           from: response)
                self?.investedSmallcases = investments.data ?? []
            }
            catch let err {
                print(err)
            }
        }
        
    }
    
    func getExitedSmallcases() {
        SCGateway.shared.getExitedSmallcases { [weak self] (data, error) in
            
            
            guard let response = data else {
                print("EXITED SMALLCASE: ERROR: \(error)")
                return
            }
            
            print("EXITED SMALLCASE: RESPONSE: \(String(describing: String(data: response, encoding: .utf8)))")
            
            do {
                let exitedSmallcaseData = try JSONDecoder().decode(ExitedSmallcaseResponse.self, from: response)
                self?.exitedSmallcases = exitedSmallcaseData.data ?? []
            }
            catch let error {
                print(error)
                
            }
            
        }
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        LoadingOverlay.shared.showLoader(view: view)
        getInvestedSmallcases()
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let destinationVC = segue.destination as? InvestmentDetailsViewController, let index = tableView.indexPathForSelectedRow?.item else {
            return
        }
        
        destinationVC.iscid = investedSmallcases[index].investment.iscid
        
    }
}



extension InvestmentsListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch  selectionType {
        case .investments:
            performSegue(withIdentifier: Constants.investmentDetailsSegueId, sender: self)
        default:
            return
        }
    }
    
}


extension InvestmentsListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch selectionType {
        case .exited:
            return exitedSmallcases.count
        case .investments:
            return investedSmallcases.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellReuseId) as? SmallcaseTableViewCell else { fatalError() }
        
        switch selectionType {
        case .investments:
            cell.smallcaseName = investedSmallcases[indexPath.item].investment.name
        case .exited:
            cell.smallcaseName = exitedSmallcases[indexPath.item].name
        }
        cell.selectionStyle = .none
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    
}

