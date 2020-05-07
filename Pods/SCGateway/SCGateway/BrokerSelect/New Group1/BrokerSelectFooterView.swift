//
//  BrokerSelectFooterView.swift
//  SCGateway
//
//  Created by Shivani on 08/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//


class BrokerSelectFooterView: UICollectionReusableView {
    
    weak var delegate: HeaderFooterTapDelegate?
    
    //MARK:- UI Component
    
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        let txt = "Don’t have a broker account?"
        label.text = txt
        label.font = UIFont(name: "GraphikApp-Regular", size: 15 )
        label.textColor = Color.TextColor.light
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate let signupButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Sign Up", for: .normal)
        button.titleLabel?.font = UIFont(name: "GraphikApp-Regular", size: 15 )
        button.setTitleColor(Color.linkBlue, for: .normal)
        return button
    }()
    
    fileprivate let stackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.alignment = .center
        sv.distribution = .fill
        sv.spacing = 4
        return sv
    }()
    
    fileprivate let containerView: UIView = {
       let view = UIView()
        view.backgroundColor = Color.backgroundLight
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //MARK:- Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupLayouts()
        signupButton.addTarget(self, action: #selector(onClickSignUp), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- Setup
    
    func setupViews() {
        addSubview(containerView)
        containerView.addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(signupButton)
    
    }
    
    func setupLayouts() {
        containerView.fillSuperview()
        containerView.addBorders(edges: .top, color: Color.border)
        stackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        stackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
    }
    
    @objc func onClickSignUp(){
        delegate?.didTapSignup()
    }
    
}
