//
//  BrokerSelectHeaderView.swift
//  SCGateway
//
//  Created by Shivani on 07/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

protocol  HeaderFooterTapDelegate: class {
    func shouldChangeLeprechaunStatus()
    func dismissPopup()
    func didTapSignup()
}

class BrokerSelectHeaderView: UICollectionReusableView {

    var numberOfTaps: Int = 0
    
    weak var delegate: HeaderFooterTapDelegate?
    //MARK:- UI Components
    
    fileprivate var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textAlignment = .left
        label.textColor = Color.TextColor.dark
        label.text = ViewState.brokerSelect.copyConfig?.title ?? ""
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    fileprivate let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Color.backgroundLight
        return view
    }()
    
    fileprivate lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = attrText(str: ViewState.brokerSelect.copyConfig?.subTitle)
        label.textColor = Color.TextColor.light
        return label
    }()
    
    fileprivate lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(images[ImageConstants.closeIcon]!, for: .normal)
        button.addTarget(self, action: #selector(didTapDismiss), for: .touchUpInside)
        return button
    }()
    
    fileprivate let stackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .fill
        sv.spacing = 8
        return sv
    }()
    
    func attrText(str: String? ) -> NSAttributedString? {
        guard let str = str  else {
            return nil
        }
        
        let attributedString = NSMutableAttributedString(string: str)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        return attributedString
    }
    
    //MARk:- Initialize
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupViews()
        setupLayout()
        addGestures()
    }
    
    func addGestures() {

        let leprechaunGesture = UITapGestureRecognizer(target: self, action: #selector(didTapContainer))
        containerView.addGestureRecognizer(leprechaunGesture)
    }
    
    //MARK:- Setup
    
    func setupViews() {
        addSubview(containerView)
        containerView.addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
        containerView.addSubview(cancelButton)
    }
    
    func setupLayout() {
        //Container View
        containerView.fillSuperview()
        
        //Stack View
        cancelButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20).isActive = true
        containerView.bringSubviewToFront(cancelButton)
        
        cancelButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20).isActive = true
        cancelButton.heightAnchor.constraint(equalToConstant: 16).isActive = true
        cancelButton.widthAnchor.constraint(equalToConstant: 16).isActive = true
        
        stackView.topAnchor.constraint(equalTo: cancelButton.topAnchor, constant: 8).isActive = true
        stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24).isActive = true
        stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24).isActive = true
        
    }
    
    //MARK:- Tap Handlers
    
    @objc func didTapDismiss() {
        print("Dismiss button tapped")
        delegate?.dismissPopup()
    }
    
    @objc func didTapContainer() {
        numberOfTaps += 1
        
        print("number of taps: \(numberOfTaps)")
        if numberOfTaps == 10 {
            delegate?.shouldChangeLeprechaunStatus()
            numberOfTaps = 0
        }
    }

}
