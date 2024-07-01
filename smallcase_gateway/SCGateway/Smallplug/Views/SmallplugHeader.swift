//
//  SmallplugHeader.swift
//  SCGateway
//
//  Created by Ankit Deshmukh on 02/06/22.
//  Copyright © 2022 smallcase. All rights reserved.
//

import UIKit

class SmallplugHeader: UIView {
    
    let smallplugHeaderXib = "SmallplugHeader"

    @IBOutlet weak var smallplugHeaderContainer: UIView!
    @IBOutlet weak var goBackStackView: UIStackView!
    @IBOutlet weak var gatewayPartnerLogo: UIImageView!
    @IBOutlet weak var backIcon: UIImageView!
    
    var backIconColor: String?
    
    var backIconColorOpacity: CGFloat? = nil
    
    var dmUiConfig: SmallplugUiConfig? = nil {
        didSet {
            self.backIcon.tintColor = UIColor(hex: dmUiConfig?.backIconColor ?? "FFFFFF", alpha: dmUiConfig?.backIconColorOpacity ?? 1.0)
        }
    }
    
    init(backIconColor: String?, backIconColorOpacity: CGFloat?) {
        self.backIconColor = backIconColor
        self.backIconColorOpacity = backIconColorOpacity
        super.init(frame: .init(origin: .zero, size: .init(width: 121, height: 28)))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Bundle.init(for: SCGateway.self).loadNibNamed(smallplugHeaderXib, owner: self, options: nil)
        
        setup()
        smallplugHeaderContainer.addCustomisations(self)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setup() {
        goBackStackView.layer.cornerRadius = 15
        
        ///Since UIStackView is a non-rendering subclass of UIView
        /// ref: https://fluffy.es/stackview-background-color/
        if #unavailable(iOS 14) {
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.init(hex: "FFFFFF", alpha: 0.12)
            
            backgroundView.layer.cornerRadius = 15
            
            backgroundView.translatesAutoresizingMaskIntoConstraints = false
            
            // put background view as the most background subviews of stack view
            goBackStackView.insertSubview(backgroundView, at: 0)
            
            // pin the background view edge to the stack view edge
            NSLayoutConstraint.activate([
                backgroundView.leadingAnchor.constraint(equalTo: goBackStackView.leadingAnchor),
                backgroundView.trailingAnchor.constraint(equalTo: goBackStackView.trailingAnchor),
                backgroundView.topAnchor.constraint(equalTo: goBackStackView.topAnchor),
                backgroundView.bottomAnchor.constraint(equalTo: goBackStackView.bottomAnchor)
            ])
        }
        
        if let iconColor = self.backIconColor, let iconAlpha = self.backIconColorOpacity {
            backIcon.image = backIcon.image?.withRenderingMode(.alwaysTemplate)
            backIcon.tintColor = UIColor(hex: iconColor, alpha: iconAlpha)
        }
        
        if let partnerLogoImage = URL(string: "https://assets.smallcase.com/images/gateway/partnerLogo/big/\(SessionManager.gatewayName!)-header.png"),
           let _ = NSData(contentsOf: partnerLogoImage) {
            gatewayPartnerLogo.load(url: partnerLogoImage)
        } else {
            gatewayPartnerLogo.isHidden = true
        }
    }
    
}

fileprivate extension UIView {
    
    func addCustomisations(_ container: UIView) -> Void{
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.frame = container.frame
        self.isUserInteractionEnabled = true
        container.addSubview(self)
        
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 2).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 2).isActive = true
        
    }
}
