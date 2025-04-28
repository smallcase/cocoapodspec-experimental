//
//  BrokerChooserViewController.swift
//  SCGateway
//
//  Created by Ankit Deshmukh on 28/06/21.
//  Copyright © 2021 smallcase. All rights reserved.
//

import UIKit
import WebKit
import AuthenticationServices
import SafariServices

class BrokerChooserViewController: UIViewController,
                                   WKUIDelegate,
                                   WKNavigationDelegate{
    

    
    //MARK: UI Variables
    lazy var webView: WKWebView = {
        let contentController = WKUserContentController()
        contentController.add(self, name: MessageHandlers.postToNativeSdk)
        contentController.add(self, name: MessageHandlers.toggleLeprechaunMode)
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController = contentController
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.isOpaque = false
        webView.scrollView.backgroundColor = .clear
        webView.backgroundColor = .clear
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()

    // Shows smallcase loading Icon
    lazy var smallcaseLoaderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.loadGif(name: Constants.loaderImageGifName)
        return imageView
    }()
    
    fileprivate lazy var transactionFinalStatusView: TransactionCompletionStatusView = {
        let view = TransactionCompletionStatusView()
        view.delegate = self
        return view
    }()
    
    fileprivate lazy var connectedConsentView: ConnectedConsentView = {
        let view = ConnectedConsentView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    fileprivate lazy var loadingView: GatewayLoadingView = {
        let lv = GatewayLoadingView()
        lv.translatesAutoresizingMaskIntoConstraints = false
        return lv
    }()
    
    fileprivate lazy var loginFallbackView: LoginFallbackView = {
        let lfv = LoginFallbackView()
        lfv.translatesAutoresizingMaskIntoConstraints = false
        lfv.viewModel = self.viewModel
        return lfv
    }()
    
    //MARK: Variables
    internal var viewModel: BrokerSelectViewModelProtocol!
    
    // Is Triggered when the onComplete popup is closed
    var transactionCompletion : ((Bool) -> Void)? = nil
    
    var viewState: ViewState = .loading(showBrokerLoading: true) {
        didSet {
            transactionFinalStatusView.brokerName = viewModel.userBrokerConfig?.brokerDisplayName
            transactionFinalStatusView.componentType = viewState
            loadingView.brokerName = viewModel.getConnectedBrokerConfig(brokersConfigArray: SessionManager.rawBrokerConfig)?.brokerDisplayName
            
            switch viewState {

                case .loading(let showBrokerLoading):
                    webView.isHidden = true
                    transactionFinalStatusView.isHidden  = true
                    connectedConsentView.isHidden = true
                    loginFallbackView.isHidden = true
                    loadingView.viewState = viewState

                    if showBrokerLoading {
                        loadingView.isHidden = false
                    }
                    else {
                        loadingView.isHidden = true
                    }

                case .loadHoldings:
                    webView.isHidden = true
                    transactionFinalStatusView.isHidden  = true
                    smallcaseLoaderImageView.isHidden = true
                    connectedConsentView.isHidden = true
                    loginFallbackView.isHidden = true
                    loadingView.isHidden = false
                    loadingView.viewState = viewState

                case .brokerSelect:
                    loadingView.isHidden = true
                    transactionFinalStatusView.isHidden  = true
                    connectedConsentView.isHidden = true
                    loginFallbackView.isHidden = true
                    webView.isHidden = false
                    openWebBrokerChooser()

                case .orderFlowWaiting:
                    webView.isHidden = true
                    loginFallbackView.isHidden = true
                    transactionFinalStatusView.isHidden = true
                    smallcaseLoaderImageView.isHidden = true
                    connectedConsentView.isHidden = true
                    loadingView.isHidden = false
                    loadingView.viewState = viewState

                case .connectedConsent(let brokerConfig):
                    loginFallbackView.isHidden = true
                    webView.isHidden = true
                    loadingView.isHidden = true
                    transactionFinalStatusView.isHidden = true
                    smallcaseLoaderImageView.isHidden = true
                    connectedConsentView.isHidden = false
                    connectedConsentView.consentBroker = brokerConfig
                    connectedConsentView.delegate = viewModel
                    
                case .preConnect(let brokerConfig):
                    loginFallbackView.isHidden = true
                    webView.isHidden = true
                    loadingView.isHidden = false
                    loadingView.brokerName = brokerConfig.brokerDisplayName
                    loadingView.viewState = viewState
                    transactionFinalStatusView.isHidden = true
                    smallcaseLoaderImageView.isHidden = true
                    connectedConsentView.isHidden = true

                case .nativeLoginFallback(let brokerConfig):
                    webView.isHidden = true
                    loadingView.isHidden = true
                    transactionFinalStatusView.isHidden = true
                    smallcaseLoaderImageView.isHidden = true
                    connectedConsentView.isHidden = true
                    loginFallbackView.brokerConfig = brokerConfig
                    loginFallbackView.isHidden = false
                    
                //For all other intermediate states, only final transaction completion view would be visible
                default:
                    webView.isHidden = true
                    loadingView.isHidden = true
                    transactionFinalStatusView.isHidden = false
                    smallcaseLoaderImageView.isHidden = true
                    connectedConsentView.isHidden = true

            }
            
        }
    }
    
    //MARK: Initialize
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
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let currentTxnStatus = SessionManager.currentTransactionIdStatus
        let isMF = currentTxnStatus?.orderConfig?.assetUniverse == ScAssetUniverse.MUTUAL_FUND.rawValue

        viewState = .loading(showBrokerLoading: (SessionManager.copyConfig?.preBrokerChooser?.show == true && !self.viewModel.showOrders && !isMF))

        setupViews()

        launchDummyUrlInWebView()
        if(isMF) {
            viewModel.openGateway(url: currentTxnStatus?.getPlatformUrl())
            return
        }

        if self.viewModel.showOrders || self.viewModel.isLogout {

            self.viewState = .loading(showBrokerLoading: false)
            viewModel.getBrokerConfig()

        } else if(SessionManager.copyConfig?.preBrokerChooser?.show == true) {

            /// Adding delay to show Loader

            SCGateway.shared.registerMixpanelEvent(
                eventName: MixpanelConstants.EVENT_GATEWAY_CONNECT_VIEWED,
                additionalProperties: [
                    "intent": SessionManager.currentIntentString ?? "NA",
                    "transactionId": SessionManager.currentTransactionId ?? "NA",
                    "transactionStatus": SessionManager.currentTransactionIdStatus?.status ?? "NA",
                ])

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                self?.viewModel.getBrokerConfig()
            }

        }
        else {
            viewModel.getBrokerConfig()
        }
    }
    
    //MARK: Setup
    func setupViews() {
        view.isOpaque = false
        view.backgroundColor = UIColor.init(white: 0, alpha: 0.8)
        view.addSubview(connectedConsentView)
        view.addSubview(webView)
        view.addSubview(loadingView)
        view.addSubview(transactionFinalStatusView)
        view.addSubview(loginFallbackView.withSize(.init(width: view.bounds.width - 20, height: 280)))
        
        //Loading View Constraints
        loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loadingView.widthAnchor.constraint(equalToConstant: view.bounds.width - 32).isActive = true
        loadingView.heightAnchor.constraint(equalToConstant: 296).isActive = true
        
        connectedConsentView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        connectedConsentView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        connectedConsentView.widthAnchor.constraint(equalToConstant: view.bounds.width - 32).isActive = true
        connectedConsentView.heightAnchor.constraint(equalToConstant: 380).isActive = true
        
        // ViewState component
        transactionFinalStatusView.centerInSuperview()
        transactionFinalStatusView.widthAnchor.constraint(equalToConstant: view.bounds.width - 32).isActive = true
        loadingView.heightAnchor.constraint(equalToConstant: 380).isActive = true
        
        //Native login fallback
        loginFallbackView.centerInSuperview()
        
        //Webview constraints
        NSLayoutConstraint.activate([
            webView.topAnchor
                .constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            webView.leftAnchor
                .constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
            webView.bottomAnchor
                .constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            webView.rightAnchor
                .constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor)
        ])
        
    }
    
    func setupSmallcaseLoader() {
        smallcaseLoaderImageView.isHidden = false
        view.addSubview(smallcaseLoaderImageView.withSize(.init(width: 127, height: 80)))
        smallcaseLoaderImageView.centerInSuperview()
    }
    
    func launchDummyUrlInWebView() {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        
        urlComponents.host = "www.google.co.in"
        
        webView.loadHTMLString("<html><body><p></p></body></html>", baseURL: nil)
    }
    
    //MARK: Launch Broker Chooser
    func openWebBrokerChooser() {
        
        webView.load(self.viewModel.getWebBrokerChooserUrl())
    }
    
    //MARK: WebView Navigation Delegate
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard
            let url = navigationAction.request.url,
            let _ = url.scheme else {
            decisionHandler(.cancel)
            return
        }
        
        decisionHandler(.allow)
    }

}

extension BrokerChooserViewController: ViewStateComponentDelegate {
    
    func onClickCancel() {
        self.transactionCompletion?(true)
        self.dismiss(animated: false, completion: nil)
        self.removeFromParent()
    }
    
}

//MARK: WebAuth Presentation Context Provider
extension BrokerChooserViewController: ASWebAuthenticationPresentationContextProviding {
    @available(iOS 13.0, *)
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.keyWindow!.windowScene else { fatalError("No Key Window Scene")}
        return ASPresentationAnchor(windowScene: windowScene )
    }
}
