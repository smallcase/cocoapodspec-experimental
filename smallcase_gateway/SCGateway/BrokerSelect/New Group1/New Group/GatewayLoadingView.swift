//
//  GatewayLoadingView.swift
//  SCGateway
//
//  Created by Shivani on 07/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import UIKit

class GatewayLoadingView: UIView {
    
    var brokerName: String? = nil {
        didSet {
            titleLabel.text = sanitize(viewState.loadingText, brokerName: brokerName)
        }
    }
    
    var viewState: ViewState = .loading(showBrokerLoading: true) {
        didSet {
            print(viewState.loadingText ?? "")
            print(viewState.loadingDescription ?? "")
            titleLabel.text = sanitize(viewState.loadingText, brokerName: brokerName )
            descriptionLabel.attributedText = setDescription(text: sanitize(viewState.loadingDescription, brokerName: SessionManager.userBrokerConfig?.brokerDisplayName))
            
            if case ViewState.loadHoldings = viewState.self {
                loaderImageView.image = UIImage.gif(name: "holdings-fetching")
            }
            else {
                loaderImageView.image = UIImage.gif(name: "connecting-loader")
            }
            
        }
    }
    
    //MARK:- UI Components
    fileprivate let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont(name: "GraphikApp-Medium", size: 16)
        label.text =  "Connecting to broker gateway"
        label.textColor = ScgatewayColor.TextColor.dark
        label.sizeToFit()
        return label
    }()
    
    fileprivate let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont(name: "GraphikApp-Regular", size: 15 )
        //Attributes
        label.textColor = ScgatewayColor.TextColor.light
        return label
    }()
    
    fileprivate let loaderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    
    //Powered By Components
    
    fileprivate let poweredByLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        let txt = "Powered by"
        label.font = UIFont(name: "GraphikApp-Regular", size: 12 )
        label.text = txt
        label.textColor = ScgatewayColor.TextColor.light
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate let poweredByImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    fileprivate let poweredByStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.alignment = .center
        sv.distribution = .fill
        sv.spacing = 5
        return sv
    }()
    
    fileprivate let poweredByContainer: UIView = {
        let view = UIView()
        view.backgroundColor = ScgatewayColor.backgroundLight
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    fileprivate let stackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.alignment = .center
        sv.distribution = .fill
        sv.spacing = 8
        return sv
    }()
    
    //MARK:- Initialize
    
    init() {
        super.init(frame: .zero)
        setupViews()
        setupLayouts()
        containerView.layer.cornerRadius = 5
//        poweredByImageView.image = images["smallcaseIcon"]!
        poweredByImageView.load(url: URL(string: "https://assets.smallcase.com/gateway/gateway-logo.png")!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setDescription(text: String?) -> NSAttributedString? {
        guard let text = text else { return nil }
        let attributedString = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3.0
        paragraphStyle.alignment = .center
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        return attributedString
        
    }
    //MARK:- Setup
    
    fileprivate func setupViews() {
        
        let dummyView = UIView()
        dummyView.heightAnchor.constraint(equalToConstant: 8).isActive = true
        dummyView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        containerView.addSubview(stackView)
        stackView.addArrangedSubview(loaderImageView)
        stackView.addArrangedSubview(dummyView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
        
        // powered by
        containerView.addSubview(poweredByContainer)
        poweredByContainer.addSubview(poweredByStackView)
        poweredByStackView.addArrangedSubview(poweredByLabel)
        poweredByStackView.addArrangedSubview(poweredByImageView)
        
        
        
    }
    
    fileprivate func setupLayouts() {
        
        
        containerView.fillSuperview()
        
        stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 48).isActive = true
        stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16).isActive = true
        stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24).isActive = true
        
        loaderImageView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width/2.5 ).isActive = true
        loaderImageView.heightAnchor.constraint(equalTo: loaderImageView.widthAnchor, multiplier: 0.32).isActive = true
        
        poweredByImageView.widthAnchor.constraint(equalToConstant: 74).isActive = true
        poweredByImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        
        //Powered By
        poweredByContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0).isActive = true
        poweredByContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0).isActive = true
        poweredByContainer.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        
        
        poweredByStackView.centerInSuperview()
        poweredByContainer.heightAnchor.constraint(equalToConstant: 52).isActive = true
        
    }
    
    
    func sanitize(_ text: String?, brokerName: String?) -> String? {
        guard var text = text else { return nil }
        let distributorName = SessionManager.gatewayName ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
        let smallcaseName = SessionManager.gateway?.displayName ?? ""
        
        text = text.replacingOccurrences(of: "<BROKER>", with: "\(brokerName ?? "")")
        text = text.replacingOccurrences(of: "<DISTRIBUTOR>", with: "\(distributorName )")
        text = text.replacingOccurrences(of: "<SMALLCASE>", with: "\(smallcaseName )")
        print(brokerName ?? "")
        print(distributorName)
        
        return text
    }
    
}
