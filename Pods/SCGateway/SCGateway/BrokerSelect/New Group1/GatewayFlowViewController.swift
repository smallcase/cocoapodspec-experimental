//

//  SCGateway
//
//  Created by Shivani on 06/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import AuthenticationServices
/**
 * @description:
 */
class GatewayFlowViewController: UIViewController {
    
    //MARK:- Reuse Ids
    
    private enum Constants {
        static let cellReuseId = "BrokerSelectCollectionViewCell"
        static let headerReuseId = "BrokerSelectHeaderReuseId"
        static let footerReuseId = "BrokerSelectFooterReeuseId"
        static let imageBaseUrl = "https://assets.smallcase.com/smallcase/assets/brokerLogo/small/"
        static let loaderImageGifName = "smallcase-loader"
        static let leprechaunActiveMessage = "Leprechaun mode on"
        static let leprechaunInactiveMessage = "Leprechaun mode off"
    }
    
    //TODO:-  Change Later
    //Shows smallcase loader gif instead of loading gateway view.
    private var showBrokerLoader = true
    
    // Is Triggered when the onComplete popup is closed
    private var transactionCompletion : ((Bool) -> Void)? = nil
    
    internal var viewModel: BrokerSelectViewModelProtocol!
    
    //.loading(showBrokerLoading: true)
    fileprivate  var viewState: ViewState = .loading(showBrokerLoading: true){
        didSet {
            
            transactionFinalStatusView.brokerName = viewModel.userBrokerConfig?.brokerDisplayName
            transactionFinalStatusView.componentType = viewState
            loadingView.brokerName = viewModel.getConnectedBrokerConfig(brokersConfigArray: Config.brokerConfig)?.brokerDisplayName
            print("GatewayFlowViewController \(viewModel.getConnectedBrokerConfig(brokersConfigArray: Config.brokerConfig)?.brokerDisplayName)")
            
            switch viewState {
                
            case .loading(let showBrokerLoading):
                brokerSelectStackView.isHidden = true
                transactionFinalStatusView.isHidden  = true
                loadingView.viewState = viewState
                
                if showBrokerLoading {
                    loadingView.isHidden = false
                }
                else {
                    loadingView.isHidden = true
                    setupSmallcaseLoader()
                }
                
            case .loadHoldings:
                brokerSelectStackView.isHidden = true
                transactionFinalStatusView.isHidden  = true
                loadingView.viewState = viewState
                loadingView.isHidden = false
                smallcaseLoaderImageView.isHidden = true
                
            case .brokerSelect:
                brokerSelectStackView.isHidden = false
                loadingView.isHidden = true
                transactionFinalStatusView.isHidden  = true
                smallcaseLoaderImageView.isHidden = true
                
            case .orderFlowWaiting:
                brokerSelectStackView.isHidden = true
                loadingView.isHidden = false
                loadingView.viewState = viewState
                transactionFinalStatusView.isHidden = true
                smallcaseLoaderImageView.isHidden = true
  
             //For all other intermediate states, only final transaction completion view would be visible
            default:
                brokerSelectStackView.isHidden = true
                loadingView.isHidden = true
                transactionFinalStatusView.isHidden = false
                smallcaseLoaderImageView.isHidden = true

            }
      
        }
    }
    
    //MARK:- UI Components
   //Container for broker selection
    fileprivate let brokerSelectPopupContainerView: UIView = {
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        return view
    }()
    
    fileprivate lazy var brokerSelectStackView: UIStackView = {
        
        let sv = UIStackView(frame: view.frame)
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    /// For handling tap events outside of the popup container
    fileprivate lazy var tapToDismissView: UIView = {
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        let gestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(handleOuterTap(sender:)))
        view.addGestureRecognizer(gestureRecogniser)
        return view
    }()
    
    fileprivate lazy var collectionViewLayout: UICollectionViewLayout = {
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 148, height: 42)
        layout.headerReferenceSize = CGSize(width: view.bounds.width, height: (requiredHeight(width: 312, labelText: ViewState.brokerSelect.copyConfig?.subTitle ?? "" , font: UIFont(name: "GraphikApp-Regular", size: 15 )!, attributed: true)+requiredHeight(width: 312, labelText: ViewState.brokerSelect.copyConfig?.title ?? "" , font: UIFont(name: "GraphikApp-Medium", size: 22 )!, attributed: false)+62))
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 10, left: (view.bounds.width - 312)/2, bottom: 24, right: (view.bounds.width - 312)/2)
        layout.footerReferenceSize = CGSize(width: view.bounds.width, height: 60)
        return layout
    }()
    
    fileprivate lazy var transactionFinalStatusView: TransactionCompletionStatusView = {
        let view = TransactionCompletionStatusView()
        view.delegate = self
        return view
        
    }()
    /// Shows smallcase loading Icon
    fileprivate lazy var smallcaseLoaderImageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.loadGif(name: Constants.loaderImageGifName)
        return imageView
    }()
    
    /// Shows Collection of supported brokers in a popup
    fileprivate lazy var brokerSelectCollectionView: ContentSizedCollectionView = {
        
        
        let cv = ContentSizedCollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        
        //Register cells
        cv.register(BrokerCollectionViewCell.self, forCellWithReuseIdentifier: Constants.cellReuseId)
        cv.register(BrokerSelectHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Constants.headerReuseId)
        cv.register(BrokerSelectFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: Constants.footerReuseId)
        
        //Delegates
        cv.delegate = self
        cv.dataSource = self
        cv.isScrollEnabled = false
        
        //Properties
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .white
        //cv.contentSize = CGSize(width: view.bounds.width, height: cv.collectionViewLayout.collectionViewContentSize.height)
        
        return cv
    }()
    
    fileprivate lazy var loadingView: GatewayLoadingView = {
        let lv = GatewayLoadingView()
        lv.translatesAutoresizingMaskIntoConstraints = false
        return lv
    }()
    
    //MARK:- Initialize
    
    init(viewModel: BrokerSelectViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
        if #available(iOS 13.0, *) {
            self.viewModel.webPresentationContextProvider = self
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        viewState = .loading(showBrokerLoading: showBrokerLoader)
        view.isOpaque = false
        view.backgroundColor = UIColor.init(white: 0, alpha: 0.8)
        setupViews()
        setupLayout()
        
        //  Adding delay to show Loader
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.viewModel.getBrokerConfig()
            
        }
    }
    
    func setupSmallcaseLoader() {
        
        smallcaseLoaderImageView.isHidden = false
        view.addSubview(smallcaseLoaderImageView.withSize(.init(width: 127, height: 80)))
        smallcaseLoaderImageView.centerInSuperview()
    }
    
    //MARK:- Setup
    
    func setupViews() {
        
        view.addSubview(brokerSelectStackView)
        view.addSubview(loadingView)
        view.addSubview(transactionFinalStatusView)
        
        brokerSelectStackView.addArrangedSubview(tapToDismissView)
        brokerSelectStackView.addArrangedSubview(brokerSelectPopupContainerView)
        
        brokerSelectPopupContainerView.addSubview(brokerSelectCollectionView)
        
    }
    
    func setupLayout() {
        
        //Loading View Constraints
        loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loadingView.widthAnchor.constraint(equalToConstant: view.bounds.width - 32).isActive = true
        loadingView.heightAnchor.constraint(equalToConstant: 380).isActive = true
        
        
        // ViewState component
        transactionFinalStatusView.centerInSuperview()
        transactionFinalStatusView.widthAnchor.constraint(equalToConstant: view.bounds.width - 32).isActive = true
        loadingView.heightAnchor.constraint(equalToConstant: 380).isActive = true
        
        //Stack View Constraints
        brokerSelectStackView.fillSuperviewSafeAreaLayoutGuide()
        
        
        //Collection View Constraints
        brokerSelectCollectionView.fillSuperview()
        
    }
    
    //MARK:- Utility
    
    @objc func handleOuterTap(sender: UIGestureRecognizer?) {
        self.dismiss(animated: false, completion: nil)
    }
}

//MARK:- CVDelegate
extension GatewayFlowViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.userBrokerConfig = viewModel.config(at: indexPath.item)!
        
    }
}

//MARK:- CVDatasource
extension GatewayFlowViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellReuseId, for: indexPath) as? BrokerCollectionViewCell else {
            fatalError()
        }
        
        guard let config = viewModel.config(at: indexPath.item) else { return cell }
        cell.title = config.brokerDisplayName
        if let brokerImage = images[config.broker] ?? nil {
            cell.image = brokerImage
            
        }
        else {
            let urlStr = "\(Constants.imageBaseUrl)\(config.broker).png"
            cell.imageUrl = URL(string: urlStr)
        }
        cell.addShadow()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Constants.headerReuseId, for: indexPath) as? BrokerSelectHeaderView else { fatalError() }
            headerView.delegate = viewModel
            return headerView
        }
            
        else if kind == UICollectionView.elementKindSectionFooter {
            guard let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.footerReuseId, for: indexPath) as? BrokerSelectFooterView else { fatalError() }
            footerView.delegate = viewModel
            return footerView
        }
        else {
            fatalError()
        }
        
    }
}

//MARK:- ViewModel Delegate
extension GatewayFlowViewController: BrokerSelectVMDelegate {
    
    
    func leprechaunStateChanged() {
        let msg = Config.isLeprechaunActive ? Constants.leprechaunActiveMessage : Constants.leprechaunInactiveMessage
        
        DispatchQueue.main.async { [weak self] in
            self?.showToast(message: msg, font: .systemFont(ofSize: 14))
        }
        
    }
    
    func changeState(to viewState: ViewState, completion: ((Bool) -> Void)?) {
        transactionCompletion = completion
        DispatchQueue.main.async { [weak self] in
            self?.viewState = viewState
            
            
            
        }
    }
    
    func showBrokerSelector() {
        DispatchQueue.main.async { [weak self] in
            self?.viewState = .brokerSelect
            self?.brokerSelectCollectionView.reloadData()
        }
    }
    
}

extension GatewayFlowViewController: ViewStateComponentDelegate {
    
    func onClickCancel() {
        self.transactionCompletion?(true)
        self.dismiss(animated: false, completion: nil)
        self.removeFromParent()
    }
 
}

extension GatewayFlowViewController: ASWebAuthenticationPresentationContextProviding {
    @available(iOS 13.0, *)
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.keyWindow!.windowScene else { fatalError("No Key Window Scene")}
        return ASPresentationAnchor(windowScene: windowScene )
    }
}
