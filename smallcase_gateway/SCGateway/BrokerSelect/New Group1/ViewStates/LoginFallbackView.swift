//
//  LoginFallbackView.swift
//  SCGateway
//
//  Created by Aaditya Singh on 09/04/25.
//  Copyright © 2025 smallcase. All rights reserved.
//

import Foundation

class LoginFallbackView: UIView {
    
    // MARK: - Properties
    
    weak var delegate: ViewStateComponentDelegate?
    internal var viewModel: BrokerSelectViewModelProtocol?
    
    var brokerName: String = ""
    var brokerConfig: BrokerConfig? {
        didSet {
            self.brokerName = brokerConfig?.broker ?? ""
            loadVariables()
        }
    }
    
    // UI Components
    private let contentView = UIView()
    
    private let brokerLogo: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let labelLoginWithBroker: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        label.textColor = .primaryTextDarkColor()
        return label
    }()
    
    private let continueOnWebButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login with User ID", for: .normal)
        button.backgroundColor = UIColor.primaryBlue()
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 4
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        return button
    }()
        
    private let crossIcon: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .crossButton()
        return button
    }()
    
    private let suggestionLabel: UILabel = {
        let label = UILabel()
        label.text = "We suggest you try login with User ID"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .primaryTextMediumColor()
        label.numberOfLines = 0
        return label
    }()
    
    private let retryLoginLabel: UILabel = {
        let label = UILabel()
        label.text = "You can also retry login with"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .primaryTextMediumColor()
        label.textAlignment = .right
        return label
    }()

    private let continueWithKiteAppButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Kite app", for: .normal)
        button.setTitleColor(UIColor.primaryBlue(), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.contentEdgeInsets = .zero
        return button
    }()

    private lazy var retryLoginStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [retryLoginLabel, continueWithKiteAppButton])
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        stack.distribution = .fill
        return stack
    }()

    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        loadVariables()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupConstraints()
        loadVariables()
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        contentView.layer.cornerRadius = 4
        contentView.backgroundColor = .white
        addSubview(contentView)
        
        [brokerLogo, labelLoginWithBroker, suggestionLabel, continueOnWebButton, retryLoginStackView, crossIcon].forEach {
            contentView.addSubview($0)
        }
        
        crossIcon.addTarget(self, action: #selector(clickedCrossIcon), for: .touchUpInside)
        continueOnWebButton.addTarget(self, action: #selector(clickedContinueOnWeb), for: .touchUpInside)
        continueWithKiteAppButton.addTarget(self, action: #selector(clickedContinueOnBrokerApp), for: .touchUpInside)

    }
    
    private func setupConstraints() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        brokerLogo.translatesAutoresizingMaskIntoConstraints = false
        labelLoginWithBroker.translatesAutoresizingMaskIntoConstraints = false
        continueOnWebButton.translatesAutoresizingMaskIntoConstraints = false
        crossIcon.translatesAutoresizingMaskIntoConstraints = false
        suggestionLabel.translatesAutoresizingMaskIntoConstraints = false
        retryLoginStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: self.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            crossIcon.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            crossIcon.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            crossIcon.widthAnchor.constraint(equalToConstant: 12),
            crossIcon.heightAnchor.constraint(equalToConstant: 12),
            
            brokerLogo.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            brokerLogo.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            brokerLogo.widthAnchor.constraint(equalToConstant: 40),
            brokerLogo.heightAnchor.constraint(equalToConstant: 40),
            
            labelLoginWithBroker.topAnchor.constraint(equalTo: brokerLogo.bottomAnchor, constant: 20),
            labelLoginWithBroker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            labelLoginWithBroker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            suggestionLabel.topAnchor.constraint(equalTo: labelLoginWithBroker.bottomAnchor, constant: 8),
            suggestionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            suggestionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            continueOnWebButton.topAnchor.constraint(equalTo: suggestionLabel.bottomAnchor, constant: 24),
            continueOnWebButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            continueOnWebButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            continueOnWebButton.heightAnchor.constraint(equalToConstant: 52),
            
            retryLoginStackView.topAnchor.constraint(equalTo: continueOnWebButton.bottomAnchor, constant: 16),
            retryLoginStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            retryLoginStackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -16)

        ])
    }
    
    // MARK: - Load Variables
    
    private func loadVariables() {
        brokerName = SessionManager.userBrokerConfig?.broker ?? ""
        labelLoginWithBroker.text = "Unable to login on \(brokerName) app?"
        
        if let brokerLogoUrl = URL(string: "https://assets.smallcase.com/smallcase/assets/brokerLogo/native/\(brokerName.lowercased()).png") {
            brokerLogo.load(url: brokerLogoUrl)
        }
    }
    
    // MARK: - Actions
    
    @objc private func clickedCrossIcon() {
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
        
        SCGateway.shared.fetchTransactionStatus(transactionId: SessionManager.currentTransactionId ?? "") { [weak self] result in
            switch result {
            case .success(let response):
                self?.viewModel?.coordinatorDelegate?.transactionErrored(error: .safariTabClosedInitialised, successData: response.data?.transaction?.success)
            case .failure(_):
                self?.viewModel?.coordinatorDelegate?.transactionErrored(error: .safariTabClosedInitialised, successData: nil)
            }
        }
    }
    
    @objc private func clickedContinueOnBrokerApp() {
        SCGateway.shared.registerMixpanelEvent(
            eventName: MixpanelConstants.EVENT_NATIVE_LOGIN_FALLBACK, additionalProperties: [
                "transactionId": SessionManager.currentTransactionId ?? "NA",
                "transactionStatus": SessionManager.currentTransactionIdStatus?.status ?? "NA",
                "intent": SessionManager.currentIntentString ?? "NA",
                "continuedWith": "app"
            ])
        
        self.viewModel?.launchNativeBrokerApp()
    }
    
    @objc private func clickedContinueOnWeb() {
        SCGateway.shared.registerMixpanelEvent(
            eventName: MixpanelConstants.EVENT_NATIVE_LOGIN_FALLBACK, additionalProperties: [
                "transactionId": SessionManager.currentTransactionId ?? "NA",
                "transactionStatus": SessionManager.currentTransactionIdStatus?.status ?? "NA",
                "intent": SessionManager.currentIntentString ?? "NA",
                "continuedWith": "web"
            ])
        
        if let viewModel = self.viewModel {
            viewModel.initiateTransactionWebView(transactionId: viewModel.transactionId, isNativeLogin: false)
        }
    }
}
