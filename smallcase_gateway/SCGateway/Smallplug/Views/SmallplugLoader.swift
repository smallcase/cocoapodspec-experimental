//
//  SmallplugLoader.swift
//  SCGateway
//
//  Created by Ankit Deshmukh on 30/05/22.
//  Copyright © 2022 smallcase. All rights reserved.
//

import UIKit

class SmallplugLoader: UIView {

    let smallplugLoaderXib = "SmallplugLoader"
    
    @IBOutlet weak var smallplugLoaderContentView: UIView!
    
    @IBOutlet weak var partnerLogo: UIImageView!
    
    @IBOutlet weak var smallcaseLoaderGif: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Bundle.init(for: SCGateway.self).loadNibNamed(smallplugLoaderXib, owner: self, options: nil)
        smallcaseLoaderGif.loadGif(name: "smallcase-loader")
        
        if let partnerLogoImage = URL(string: "https://assets.smallcase.com/images/gateway/partnerLogo/big/\(SessionManager.gatewayName!).png") {
            partnerLogo.load(url: partnerLogoImage)
        }
        
        smallplugLoaderContentView.addCustomisations(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

fileprivate extension UIView {
    
    func addCustomisations(_ container: UIView) -> Void{
        self.translatesAutoresizingMaskIntoConstraints = false
        self.frame = container.frame
        self.layer.cornerRadius = 11
        self.clipsToBounds = true
        self.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        self.backgroundColor = .white
        
        container.addSubview(self)
        
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        
    }
}
