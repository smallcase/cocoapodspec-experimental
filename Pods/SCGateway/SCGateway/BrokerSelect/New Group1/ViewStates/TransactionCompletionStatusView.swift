//
//  BrokerConnectedView.swift
//  SCGateway
//
//  Created by Shivani on 14/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//


protocol ViewStateComponentDelegate: class {
    func onClickCancel()
}
/**
 * View Component shown After Transaction Success / Failed
 */
class TransactionCompletionStatusView: UIView {
    
    fileprivate enum StringType {
        case title
        case subtitle
        case body
    }
    
    var componentType: ViewState? {
        didSet {
            copyConfig = componentType?.copyConfig
            initializeData()
        }
    }
    
    var copyConfig: CopyConfig?
    
    var brokerName: String?
    
    var smallcaseName: String?
    
    weak var delegate: ViewStateComponentDelegate?
    
    
    //MARK:- UI Components
    fileprivate var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    fileprivate var imageView: UIImageView = {
        let imgView = UIImageView()
        // imgView.backgroundColor = .green
        return imgView
    }()
    
    fileprivate var titleLabel: UILabel = {
        
        let label = UILabel()
        label.textColor = Color.TextColor.dark
        label.font = UIFont(name: "GraphikApp-Medium", size: 16)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    fileprivate var descriptionLabel: UILabel = {
        
        let label = UILabel()
        label.textColor = Color.TextColor.light
        label.font = UIFont(name: "GraphikApp-Regular", size: 15 )
        label.numberOfLines = 0
        return label
    }()
    
    fileprivate lazy var ctaButton: UIButton = {
        
        let button = UIButton()
        button.addTarget(self, action: #selector(handleCtaButton), for: .touchUpInside)
        return button
    }()
    
    fileprivate var redirectLabel:  UILabel = {
        
        let label = UILabel()
        label.textColor = Color.TextColor.light
        label.textAlignment = .center
        label.font = UIFont(name: "GraphikApp-Regular", size: 14 )
        return label
    }()
    
    fileprivate lazy var cancelButton: UIButton = {
        
        let button = UIButton()
        button.setImage(images[ImageConstants.closeIcon]!, for: .normal)
        button.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        return button
    }()
    
    fileprivate var redirectStack: UIStackView = UIStackView()
    
    fileprivate var buttonStack: UIStackView = UIStackView()
    
    fileprivate var timerString: Int = -1 {
        didSet {
            
            redirectLabel.text = "Redirecting you to \(Config.gatewayName!) in \(timerString)"
            if timerString == 0  {
                timer.invalidate()
                isTimerRunning = false
                delegate?.onClickCancel()
            }
        }
    }
    fileprivate var timer = Timer()
    
    fileprivate var isTimerRunning = false
    
    func startTimer() {
        if isTimerRunning  {return}
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer) , userInfo: nil, repeats: true)
        isTimerRunning = true
    }
    
    @objc func updateTimer() {
        timerString -= 1
    }
    
    //MARK:- Initialize
    init() {
        
        super.init(frame: .zero)
        setup()
        containerView.layer.cornerRadius = 4
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- Setup
    
    func setup() {
        
        addSubview(containerView)
        containerView.fillSuperview()
        addSubview(cancelButton)
        cancelButton.anchor(top: topAnchor, leading: nil, bottom: nil, trailing: trailingAnchor, padding: .init(top: 16, left: 0, bottom: 16, right: 16), size: .init(width: 24, height: 24))
        
        
        buttonStack = stack(UIView(), ctaButton.withSize(.init(width: 180, height: 44)), spacing: 8, alignment: .center, distribution: .fill)
        redirectStack = stack(UIView(), redirectLabel, spacing: 16, alignment: .center, distribution: .fill)
        
        let contentStack = stack(titleLabel, descriptionLabel, buttonStack , spacing: 8, alignment: .center, distribution: .fill)
        
        containerView.stack(imageView.withSize(.init(width: 44, height: 44)), contentStack, redirectStack, spacing: 32, alignment: .center, distribution: .fill).withMargins(.init(top: 56, left: 32, bottom: 56, right: 32))
        setNeedsDisplay()
        
    }
    
    func setupButton() {
        
       ctaButton.titleLabel?.font =  UIFont(name: "GraphikApp-Medium", size: 15 )
        
        switch componentType! {
        case .orderInQueue:
            ctaButton.setTitle("Got it" , for: .normal)
            ctaButton.tintColor = Color.linkBlue
            ctaButton.backgroundColor = .clear
            ctaButton.setTitleColor(Color.linkBlue, for: .normal)
            
        default:
            
            return
        }
    }
    
    
    func sanitize(_ text: String?) -> String? {
        guard var text = text else { return nil }
        let distributorName = Config.gatewayName ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
        
        text = text.replacingOccurrences(of: "<BROKER>", with: "\(brokerName ?? "")")
        text = text.replacingOccurrences(of: "<SMALLCASE>", with: "\(smallcaseName ?? "")")
        text = text.replacingOccurrences(of: "<DISTRIBUTOR>", with: "\(distributorName )")
        
        return text
    }
    
    func initializeData() {
        
        let title = sanitize(copyConfig?.title)
        
        imageView.image = componentType?.iconImage
        
        setup(text: title, stringType: .title)
        setupButton()
        
        switch componentType! {
        case .connected:
            let subTitle = sanitize(copyConfig?.subTitle)
            timerString = 5
            setup(text: subTitle, stringType: .subtitle)
            buttonStack.isHidden = true
            redirectStack.isHidden = false
            cancelButton.isHidden = true
            startTimer()
            
        case .loginFailed:
            setup(text: copyConfig?.wrongUser, stringType: .subtitle)
            buttonStack.isHidden = true
            redirectStack.isHidden = true
            cancelButton.isHidden = false
    
        case .orderInQueue:
            let subTitle = sanitize(copyConfig?.subTitle)
            setup(text: subTitle, stringType: .subtitle)
            redirectStack.isHidden = true
            buttonStack.isHidden = false
            cancelButton.isHidden = false
            
            
            
        default:
            return
            
            
        }
    }
    
    fileprivate func setup(text: String?, stringType: StringType) {
        
        guard let text = text else { return }
        
        let attributedString = NSMutableAttributedString(string: text)
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.lineHeightMultiple = 1.2
        paraStyle.alignment = .center
        
        
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paraStyle, range:NSMakeRange(0, attributedString.length))
        
        switch stringType {
        case .title:
            titleLabel.attributedText = attributedString
        case .subtitle:
            descriptionLabel.attributedText = attributedString
        default:
            return
        }
        
    }
    
}

//MARK:- Actions

extension TransactionCompletionStatusView {
    
    @objc func didTapCancel() {
        delegate?.onClickCancel()
    }
    
    @objc func handleCtaButton() {
        if case ViewState.orderInQueue = componentType! {
            delegate?.onClickCancel()
        }
    }
}

