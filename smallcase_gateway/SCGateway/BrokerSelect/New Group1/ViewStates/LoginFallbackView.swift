//
//  LoginFallbackView.swift
//  SCGateway
//
//  Created by Ankit Deshmukh on 14/06/22.
//  Copyright © 2022 smallcase. All rights reserved.
//

import UIKit

class LoginFallbackView: UIView {
    
    let loginFallbackXib = "LoginFallbackView"
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var labelLoginWithBroker: UILabel!
    @IBOutlet weak var brokerLogo: UIImageView!
    @IBOutlet weak var btnContinueOnBroker: UIButton!
    @IBOutlet weak var btnContinueWithWeb: UIButton!
    
    @IBOutlet weak var crossIcon: UIButton!
    
    @IBAction func clickedCrossIcon(_ sender: Any) {
        SCGateway.shared.registerMixpanelEvent(
            eventName: MixpanelConstants.EVENT_USER_CLOSED,
            additionalProperties: [
                "transactionId": SessionManager.currentTransactionId ?? "NA",
                "transactionStatus": SessionManager.currentTransactionIdStatus?.status ?? "NA",
                "intent": SessionManager.currentIntentString ?? "NA",
                "error_code": TransactionError.safariTabClosedInitialised.rawValue,
                "error_message": TransactionError.safariTabClosedInitialised.message
            ])
        
        self.viewModel?.markTransactionErrored(.safariTabClosedInitialised)
        self.viewModel?.coordinatorDelegate?.transactionErrored(error: .safariTabClosedInitialised, successData: nil)
    }
    
    
    @IBAction func clickedContinueOnBrokerApp(_ sender: Any) {
        SCGateway.shared.registerMixpanelEvent(
            eventName: MixpanelConstants.EVENT_NATIVE_LOGIN_FALLBACK, additionalProperties: [
                "transactionId": SessionManager.currentTransactionId ?? "NA",
                "transactionStatus": SessionManager.currentTransactionIdStatus?.status ?? "NA",
                "intent": SessionManager.currentIntentString ?? "NA",
                "continuedWith": "app"
            ])
        
        self.viewModel?.launchNativeBrokerApp()
    }
    
    @IBAction func clickedContinueOnWeb(_ sender: Any) {
        SCGateway.shared.registerMixpanelEvent(
            eventName: MixpanelConstants.EVENT_NATIVE_LOGIN_FALLBACK, additionalProperties: [
                "intent": SessionManager.currentIntentString ?? "NA",
                "transactionId": SessionManager.currentTransactionId ?? "NA",
                "transactionStatus": SessionManager.currentTransactionIdStatus?.status ?? "NA",
                "continuedWith": "web"
            ])
        
        if let viewModel = self.viewModel {
            viewModel.initiateTransactionWebView(transactionId: viewModel.transactionId, isNativeLogin: false)
        }
    }
    
    var brokerName: String = ""
    
    var brokerConfig: BrokerConfig? = nil {
        didSet {
            self.brokerName = brokerConfig?.broker ?? ""
            loadVariables()
        }
    }
    
    weak var delegate: ViewStateComponentDelegate?
    
    internal var viewModel: BrokerSelectViewModelProtocol?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.init(for: SCGateway.self).loadNibNamed(loginFallbackXib, owner: self, options: nil)
        contentView.layer.cornerRadius = 4
        
        addSubview(contentView)
        contentView.frame = self.bounds
        self.brokerName = SessionManager.userBrokerConfig?.broker ?? ""

        loadVariables()
    }
    
    private func loadVariables() {
        labelLoginWithBroker.text = "Login with \(brokerName.capitalized)"
        
        if let brokerLogoUrl = URL(string: "https://assets.smallcase.com/smallcase/assets/brokerLogo/native/\(brokerName.lowercased()).png") {
            brokerLogo.load(url: brokerLogoUrl)
        }
        
        btnContinueOnBroker.setTitle("Continue on \(brokerName.capitalized) app", for: UIControl.State.normal)
    }
    
}
