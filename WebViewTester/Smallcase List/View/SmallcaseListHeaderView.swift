//
//  SmallcaseListHeaderView.swift
//  WebViewTester
//
//  Created by Shivani on 17/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import UIKit

protocol SmallcaseListHeaderDelegate: AnyObject {
    func showInvestments()
}

class SmallcaseListHeaderView: UIView {
    
    weak var delegate: SmallcaseListHeaderDelegate?
    
    var viewInvestmentsLabel: UILabel = {
        let label = UILabel()
        label.text = "View Investments"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        return label
    }()
    
    
    @objc func onClickInvestments() {
        delegate?.showInvestments()
    }
    var gestureRecogniser: UIGestureRecognizer!
    
    init() {
        
        super.init(frame: .zero)
        addSubview(viewInvestmentsLabel)
        viewInvestmentsLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        viewInvestmentsLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        gestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(onClickInvestments))
        addGestureRecognizer(gestureRecogniser)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
