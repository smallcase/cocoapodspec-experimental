//
//  BrokerCollectionViewCell.swift
//  SCGateway
//
//  Created by Shivani on 06/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

internal class BrokerCollectionViewCell: UICollectionViewCell {
    
    var title: String? {
        didSet {
            titleLabel.text = title
            titleLabel.textColor = Color.TextColor.normal
            titleLabel.tintColor = Color.TextColor.normal
            
        }
    }
    var imageUrl: URL? {
        didSet {
            guard let imageUrl = imageUrl else { return }
            iconImageView.load(url: imageUrl)
        }
    }
    
    var image: UIImage? {
        didSet {
            iconImageView.image = image
        }
    }
    
    //MARK:- UI Components
    fileprivate let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    fileprivate let stackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.alignment = .center
        sv.distribution = .fill
        sv.spacing = 8
        return sv
        
        
    }()
    
    fileprivate let iconImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "GraphikApp-Medium", size: 13 )
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.blue
        label.tintColor = UIColor.blue
        
        return label
    }()
    
    
    //MARK:- Setup
    
    func setupViews() {
        addSubview(containerView)
        containerView.addSubview(stackView)
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(titleLabel)
        
    }
    
    func setupLayouts() {
        
        
        //ContainerView
        containerView.fillSuperview()
        
        // Stack View
        stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0).isActive = true
        stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12).isActive = true
        stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0).isActive = true
        
        // Icon VIew
        iconImageView.widthAnchor.constraint(equalToConstant: 16).isActive = true
        iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor, multiplier: 1).isActive = true
        
        
    }
    
    //MARK:- Initialize
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        //Setup
        setupViews()
        setupLayouts()
        
        //Border
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = Color.border.cgColor
        containerView.layer.cornerRadius = 2
        
        //self.containerView.addShadow()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BrokerCollectionViewCell {
    func addShadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0.1)
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 0.1
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.containerView.layer.cornerRadius).cgPath
        
    }
}
