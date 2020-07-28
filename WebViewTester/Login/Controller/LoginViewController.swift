//
//  LoginViewController.swift
//  WebViewTester
//
//  Created by Shivani on 12/06/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import UIKit
import SCGateway
import PopupDialog

let BrokerList = [
    "fivepaisa",
    "aliceblue",
    "axis",
    "hdfc",
    "kotak",
    "kite",
    
]

//struct Config: GatewayConfig {
//
//    var gatewayName: String
//
//    var brokerConfig: BrokerConfigType
//
//    var apiEnvironment: Environment
//
//    var isLeprechaunActive: Bool
//
//
//}

class LoginViewController: UIViewController {
    
    let createSegueId = "CreateSegue"
    
    let cellReuseId = "BrokerCellReuseID"
    
    var smallcaseAuthToken: String? {
        didSet {
            if smallcaseAuthToken != nil {
                gatewayInitialize()
            }
        }
    }
    
    var userNameString: String? {
        didSet {
            if let inputStr = userNameString {
                print(inputStr)
                getAuthToken()
                //TODO: GET SDKAuthCall
            }
        }
    }
    
    //MARK:- Components
    
    lazy var tapRecognizer: UITapGestureRecognizer = {
        var recognizer = UITapGestureRecognizer(target:self, action: #selector(dismissKeyboard))
        return recognizer
    }()
    
    
    @IBOutlet weak var envSegmentControl: UISegmentedControl!
    @IBOutlet weak var smartInvestingEnvSegmentControl: UISegmentedControl!
    
    
    @IBOutlet weak var brokerListTableView: UITableView! {
        didSet {
            brokerListTableView.isHidden = true
            brokerListTableView.delegate = self
            brokerListTableView.dataSource = self
            brokerListTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseId)
        }
    }
    
    @IBOutlet weak var gatewayNameTextField: UITextField! {
        didSet{
            gatewayNameTextField.delegate = self
            gatewayNameTextField.text = UserDefaults.standard.string(forKey: Constant.gatewayKey)
            
        }
    }
    
    @IBOutlet weak var leprechaunSwitch: UISwitch!
    
    @IBOutlet weak var brokerConfigSwitch: UISwitch!
    
    @IBAction func leprechaunSwitchToggled(_ sender: Any) {}
    
    @IBAction func brokerConfigToggled(_ sender: Any) {
        guard let sender = sender as? UISwitch else { return }
        brokerListTableView.isHidden = !sender.isOn
    }
    
    var shouldConnect: Bool = false
    //MARK:- Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gatewayNameTextField.text = "gatewaydemo"
        SCGateway.shared.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    
    //MARK:- Actions
    
    @IBAction func onClickInfo(_ sender: Any) {
        var msg  = "Not Logged in"
        
        if let username = UserDefaults.standard.string(forKey: UserDefaultConstants.userId) {
            msg = "Username :\t \(username)" + "\nConnected :\t \(UserDefaults.standard.bool(forKey: UserDefaultConstants.isConnected) )"
            
            
        }
        let popupDialog = PopupDialog(title: "Status", message: msg)
        self.present(popupDialog, animated: false, completion: nil)
        
    }
    
    func setupUser() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let brokerConfig = self.brokerConfigSwitch.isOn ?  self.getSelectedBrokers() : []
                   
            let config = GatewayConfig(gatewayName: self.gatewayNameTextField.text ?? "",
                                              brokerConfig: brokerConfig ,
                                              apiEnvironment: self.getApiEnv(index: self.envSegmentControl.selectedSegmentIndex),
                                              isLeprechaunActive: self.leprechaunSwitch.isOn)
            SCGateway.shared.setup(config: config){data,error in
                print(data)
            }
        }
       
    }
    
    @IBAction func onClickSetup(_ sender: Any?) {
        
        setupUser()
        ENVIRONMENT = getApiEnv(index: smartInvestingEnvSegmentControl.selectedSegmentIndex)
        
        promptForInput()
        
    }
    
    @IBAction func onChangeSmartInvestingEnv(_ sender: UISegmentedControl) {
        ENVIRONMENT = getApiEnv(index: sender.selectedSegmentIndex)
    }
    
   
    @IBAction func OnClickTransactionId(_ sender: Any) {
        promptForTransactionId()
    
    }
    
   
    @IBAction func copyToClipBoard(_ sender: Any){
        UIPasteboard.general.string = SCGateway.currentTransactionId
    }
    
    func promptForTransactionId() {
        
        let ac = UIAlertController(title: "Enter transactionId", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Trigger Transaction", style: .default) { [weak self] _ in
            //  let answer =
            
            self?.connectGateway(transactionId: ac.textFields![0].text ?? "")
            // do something interesting with "answer" here
        }
        
        ac.addAction(submitAction)
        
        present(ac, animated: true)
    }
    
    @IBAction func onClickConnect(_ sender: Any) {
        
        createTransaction()
    }
    
    func promptForInput() {
        
        let ac = UIAlertController(title: "Enter email/username", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Connect", style: .default) { [weak self] _ in
            //  let answer =
            self?.userNameString = ac.textFields![0].text
            
            // do something interesting with "answer" here
        }
        
        ac.addAction(submitAction)
        
        present(ac, animated: true)
    }
    
    //MARK:- Gateway
    
    func getSelectedBrokers() -> [String] {
        var customBrokerList: [String] = []
        brokerListTableView.indexPathsForSelectedRows?.forEach({ (indexPath) in
            customBrokerList.append(BrokerList[indexPath.item])
        })
        
        return customBrokerList
    }
    
    func getApiEnv(index: Int) -> Environment {
        
        switch index {
        case 0:
            return .production
        case 1:
            return .development
        case 2:
            return .staging
        default:
            return .production
        }
    }
    
    @IBAction func logoutUser(_ sender: Any) {
        
        print("Logout: Triggered")
        
        let storage = HTTPCookieStorage.shared
        
        if let cookies = storage.cookies{
            for cookie in cookies {
                print("Logout: Clear cookie: \(cookie)")
                storage.deleteCookie(cookie)
            }
        }
        
        //HTTPCookieStorage.shared.removeCookies(since: Date(timeIntervalSince1970: 0))
    }
    func getAuthToken() {
        NetworkManager.shared.getAuthToken(username: userNameString!) {[weak self] (result) in
            switch result {
            case .success(let response):
                print(response)
                guard let authToken = response.smallcaseAuthToken, let username = self?.userNameString else { return }
                self?.smallcaseAuthToken = authToken
                
                UserDefaults.standard.set(authToken, forKey: UserDefaultConstants.authToken)
                UserDefaults.standard.set(username, forKey: UserDefaultConstants.userId)
                UserDefaults.standard.set(response.connected, forKey: UserDefaultConstants.isConnected)
            case .failure(let error):
                print(error)
                
            }
        }
    }
    
    func gatewayInitialize() {
        
        print("Initialize gateway")
        //  gatewayName: "gatewaydemo"
        SCGateway.shared.initializeGateway(sdkToken: smallcaseAuthToken!) { data, error in
            
            if !data {
                print(error)
                
                if let error = error as? TransactionError {
                    self.showPopup(title: "Error", msg: error.message)
                }
                else {
                    self.showPopup(title: "Error", msg: error.debugDescription)
                }
                return
            }
            print(data)
        }
        
    }
    
    
    func connectGateway(transactionId: String) {
        
        do {
            try SCGateway.shared.triggerTransactionFlow(transactionId: transactionId , presentingController: self) { [weak self]  result in
                switch result {
                case .success(let response):
                    print("CONNECT: RESPONSE: \(response)")
                    switch response {
                    case let .connect(authToken, _):
                        self?.connect(authToken: authToken)
                    self?.showPopup(title: "Connect Complete", msg: "authToken: \(authToken)")
                        
                    case let .transaction(authToken, transactionData):
                        self?.showPopup(title: "Transaction Response", msg: " authTOken : \(authToken), \n data: \(transactionData)")
                        return
                    
                
                        //TODO: - Handle Later
                    
                    case .holdingsImport(let smallcaseAuthToken, let status, let transactionId):
                        return
                    }
                    
                    
                case .failure(let error):
                    
                    print("CONNECT: ERROR :\(error)")
                    self?.showPopup(title: "Error", msg: "\(error.message)  \(error.rawValue)")
                    
                }
                print(result)
            }
        }
        catch SCGatewayError.uninitialized {
            print(SCGatewayError.uninitialized.message)
            ///initialize gateway
        }
        catch let err {
            print(err)
        }
    }
    
    
    //MARK:- Extras
    
    func createTransaction() {
        
        guard let userName = userNameString else { return }
        let transactionParams = CreateTransactionBody(id: userName, intent: IntentType.connect.rawValue, orderConfig: nil)
        
        //     let transactionParams = CreateTransactionBody(id: userName, intent: IntentType.transaction.rawValue, orderConfig: OrderConfig(type: "BUY", scid: "SCET_0010", iscid: nil, did: nil, orders: nil))
        //
        NetworkManager.shared.getTransactionId(params: transactionParams) { [weak self] (result) in
            switch result {
            case .success(let response):
                print("response: \(response)")
                guard let transactionId = response.transactionId else {
                    self?.showErrorPopup(msg: response.err)
                    return }
                self?.connectGateway(transactionId: transactionId)
                
            case .failure(let error):
                DispatchQueue.main.async { [weak self] in
                    let popupDialog = PopupDialog(title: "Error", message: error.localizedDescription)
                    self?.present(popupDialog, animated: true, completion: nil)
                }
                print("error: \(error)")
                
            }
        }
    }
    
    
    
    func showErrorPopup(msg: String?) {
        DispatchQueue.main.async { [weak self] in
            let popupDialog = PopupDialog(title: "Error", message: msg)
            self?.present(popupDialog, animated: true, completion: nil)
        }
    }

    
}


extension LoginViewController: UITextFieldDelegate {
    
    @objc func dismissKeyboard() {
        gatewayNameTextField.resignFirstResponder()
        
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



extension LoginViewController: UITableViewDelegate { }


extension LoginViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BrokerList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseId, for: indexPath)
        cell.textLabel?.text = BrokerList[indexPath.item]
        cell.selectionStyle = .blue
        return cell
        
    }
    
    
}

extension LoginViewController: SCGatewayTransactionDelegate {
    func connectCompleted(authToken: String?) {
        guard let authToken = authToken else { return }
        connect(authToken: authToken)
    }
    
    
    func transactionDidFinish() {
        // getAuthToken()
    }
    
    func shouldDisplayConnectCompletion() -> Bool {
        return true
    }
    
    func connect(authToken: String) {
        
        NetworkManager.shared.connectBroker(
            userId: userNameString!,
            authToken: authToken) { [weak self] (result) in
                 print("LOGINVC: -> CONNECT BROKER --------> \(result)")
                switch result {
                
                case .success(let isConnected):
                    UserDefaults.standard.set(authToken, forKey: UserDefaultConstants.authToken)
                    UserDefaults.standard.set(isConnected, forKey: UserDefaultConstants.isConnected)
                    
                default:
                    return
                }
                
                self?.smallcaseAuthToken = authToken

        }
    }
    
}
