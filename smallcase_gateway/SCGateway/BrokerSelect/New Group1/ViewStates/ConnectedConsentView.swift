//
//  ConnectedConsentView.swift
//  SCGateway
//
//  Created by Dip on 13/08/20.
//  Copyright © 2020 smallcase. All rights reserved.
//

import Foundation


protocol  ConnectedConsentDelegate: AnyObject {
    func clickedDismiss()
    func consentGiven(brokerConfig:BrokerConfig)
}


class ConnectedConsentView: UIView {
    
    weak var delegate: ConnectedConsentDelegate?
    
    var consentBroker:BrokerConfig?{
        didSet{
            guard let broker = consentBroker else {return}

//            subTitleLabel.text = "Trade, track & manage investments on \(Config.gateway!.displayName!)"
            switch SessionManager.currentIntent {
                case .holdingsImport:
                    subTitleLabel.text = SessionManager.copyConfig?.clickToContinue?.subTitle2?.holdingsImport?.sanitizeDistributor(brokerDisplayName: SessionManager.gateway?.displayName ?? "").sanitizeBroker(brokerName: broker.brokerDisplayName!)
                case .fetchFunds:
                    subTitleLabel.text = SessionManager.copyConfig?.clickToContinue?.subTitle2?.fetchFunds?.sanitizeDistributor(brokerDisplayName: SessionManager.gateway?.displayName ?? "").sanitizeBroker(brokerName: broker.brokerDisplayName!)
                case .transaction:
                    subTitleLabel.text = SessionManager.copyConfig?.clickToContinue?.subTitle2?.transaction?.sanitizeDistributor(brokerDisplayName: SessionManager.gateway?.displayName ?? "").sanitizeBroker(brokerName: broker.brokerDisplayName!)
                default:
                    subTitleLabel.text = SessionManager.copyConfig?.clickToContinue?.subTitle2?.defaultCase?.sanitizeDistributor(brokerDisplayName: SessionManager.gateway?.displayName ?? "").sanitizeBroker(brokerName: broker.brokerDisplayName!)
            }
            
            descriptionLabel.attributedText = broker.gatewayLoginConsent?.sanitizeDistributor(brokerDisplayName: SessionManager.gateway?.displayName ?? "").processText(del1: "<style>", del2: "</style>", textSize: 14)
            
            continueWithBrokerLabel.text = "Continue with \(broker.brokerDisplayName ?? "")"
           
            brokerImageView.load(url: URL(string:"https://assets.smallcase.com/smallcase/assets/brokerLogo/small/\(broker.broker).png")!)
        }
    }
    
       //MARK:- UI Components
       fileprivate let containerView: UIView = {
           let view = UIView()
           view.backgroundColor = UIColor.white
           view.translatesAutoresizingMaskIntoConstraints = false
            view.layer.cornerRadius = 4
           
           return view
       }()
    
    fileprivate lazy var cancelButton: UIButton = {
           
           let button = UIButton()
           button.setImage(images[ImageConstants.closeIcon]!, for: .normal)
           button.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
           return button
       }()
       
    @objc private func didTapCancel(){
        delegate?.clickedDismiss()
    }
       fileprivate let titleLabel: UILabel = {
           let label = UILabel()
           label.translatesAutoresizingMaskIntoConstraints = false
           label.textAlignment = .center
           label.font = UIFont(name: "GraphikApp-Medium", size: 18)
           label.text =  "Login to Continue"
           label.textColor = ScgatewayColor.TextColor.dark
            label.sizeToFit()
           return label
       }()
    
    fileprivate let subTitleLabel: UILabel = {
              let label = UILabel()
              label.translatesAutoresizingMaskIntoConstraints = false
              label.textAlignment = .center
                label.numberOfLines = 0
              label.font = UIFont(name: "GraphikApp-Regular", size: 14)
              label.textColor = ScgatewayColor.TextColor.normal
              label.sizeToFit()
              return label
          }()
       
    
    fileprivate let desriptionStackContainer: UIStackView = {
       let stack = UIStackView()
        stack.layer.cornerRadius = 4
        stack.layer.borderColor = ScgatewayColor.border.cgColor
        stack.layer.borderWidth = 1.0
        let backgroundView = UIView()
        backgroundView.backgroundColor = ScgatewayColor.signupFooterBackgroundColor
        backgroundView.layer.borderWidth = 1
        backgroundView.layer.borderColor = ScgatewayColor.border.cgColor
        backgroundView.layer.cornerRadius = 4
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        // put background view as the most background subviews of stack view
        stack.insertSubview(backgroundView, at: 0)
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: stack.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: stack.bottomAnchor)
        ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fill
        stack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        stack.isLayoutMarginsRelativeArrangement = true
        return stack
    }()
    
       fileprivate let descriptionLabel: UILabel = {
           let label = UILabel()
           label.translatesAutoresizingMaskIntoConstraints = false
           label.numberOfLines = 0
           label.font = UIFont(name: "GraphikApp-Regular", size: 14 )
           //Attributes
           
           label.textColor = ScgatewayColor.TextColor.light
            return label
       }()
    
       //Powered By Components
       
       fileprivate let continueWithBrokerLabel: UILabel = {
           let label = UILabel()
           label.textAlignment = .center
           label.font = UIFont(name: "GraphikApp-Medium", size: 14 )
        label.textColor = ScgatewayColor.TextColor.bold
           label.translatesAutoresizingMaskIntoConstraints = false
           return label
       }()
       
       fileprivate let brokerImageView: UIImageView = {
           let imgView = UIImageView()
           imgView.translatesAutoresizingMaskIntoConstraints = false
           return imgView
       }()
       
    fileprivate let continueWithBrokerContainer: UIView = {
       let view = UIView()
        view.layer.cornerRadius = 4
        view.layer.borderColor = ScgatewayColor.border.cgColor
        view.layer.borderWidth = 1
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
    }()
    
    @objc func checkAction(sender : UITapGestureRecognizer) {
    delegate?.consentGiven(brokerConfig: consentBroker!)
    }
    
    fileprivate let continueStack:UIStackView = {
       let stack = UIStackView()
         stack.translatesAutoresizingMaskIntoConstraints = false
               stack.axis = .horizontal
               stack.alignment = .center
               stack.distribution = .equalCentering
               stack.spacing = 10
        stack.isUserInteractionEnabled = true
        return stack
    }()
       
    //MARK: Initialize
       
    init() {
           super.init(frame: .zero)
           setupLayouts()
    }
       
    required init?(coder aDecoder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }
       
    fileprivate func setupLayouts() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(checkAction(sender:)))
        continueWithBrokerContainer.addGestureRecognizer(tapGesture)
        addSubview(containerView)
        containerView.fillSuperview()
        containerView.addSubview(titleLabel)
        containerView.addSubview(cancelButton)
        containerView.addSubview(subTitleLabel)
        containerView.addSubview(desriptionStackContainer)
        desriptionStackContainer.addArrangedSubview(descriptionLabel)
        containerView.addSubview(continueWithBrokerContainer)
        continueWithBrokerContainer.addSubview(continueStack)
        continueStack.addArrangedSubview(brokerImageView)
        continueStack.addArrangedSubview(continueWithBrokerLabel)
        
        
        cancelButton.anchor(containerView.topAnchor, left: nil, bottom: nil, right: containerView.rightAnchor, topConstant: 16, leftConstant: 0, bottomConstant: 0, rightConstant: 16, widthConstant: 20 , heightConstant: 20)
        titleLabel.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: 5).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 30).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -30).isActive = true
        titleLabel.widthAnchor.constraint(equalToConstant: containerView.bounds.width - 30).isActive = true
       
        
        subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        subTitleLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 30).isActive = true
        subTitleLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -30).isActive = true
        desriptionStackContainer.topAnchor.constraint(equalTo: subTitleLabel.bottomAnchor, constant: 24).isActive = true
         desriptionStackContainer.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 30).isActive = true
         desriptionStackContainer.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -30).isActive = true
        
         desriptionStackContainer.widthAnchor.constraint(equalToConstant: containerView.bounds.width - 60).isActive = true
        
        brokerImageView.constrainWidth(20)
        brokerImageView.constrainHeight(20)
        
        continueWithBrokerContainer.widthAnchor.constraint(equalToConstant: 220).isActive = true
        
        continueWithBrokerContainer.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        continueWithBrokerContainer.topAnchor.constraint(equalTo: desriptionStackContainer.bottomAnchor  , constant: 16).isActive = true
     
        continueWithBrokerContainer.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        continueStack.centerYAnchor.constraint(equalTo: continueWithBrokerContainer.centerYAnchor).isActive = true
        
        continueStack.centerXAnchor.constraint(equalTo: continueWithBrokerContainer.centerXAnchor).isActive = true
     
        
        setNeedsDisplay()
           
       }
}
