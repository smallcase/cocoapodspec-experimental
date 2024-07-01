//
//  MutualFundsViewController.swift
//  SCGateway
//
//  Created by Indrajit Roy on 08/09/22.
//  Copyright © 2022 smallcase. All rights reserved.
//

import Foundation
import WebKit

class MFViewController: UIViewController, WKUIDelegate {
    internal var viewModel: MFViewModel
    enum MessageHandlers {
        static let dispatch = "dispatch"
    }
    enum State {
        case Idle
        case WebViewClosedByBackButton
        case TxnResponseSentToPartner(SdkPartnerResponse)
        case WebViewErrored
    }
    
    init(viewModel: MFViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    lazy var webView: WKWebView = {
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true

        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(self, name: MessageHandlers.dispatch)
        configuration.allowsInlineMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []

        configuration.preferences = preferences
        
        let webView = WKWebView(frame: self.view.frame, configuration: configuration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.isOpaque = false
        webView.scrollView.backgroundColor = .clear
        webView.backgroundColor = .init(hex: "000000", alpha: 0.1)
        webView.clipsToBounds = true
        
        return webView
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        self.view.backgroundColor = .clear
        self.view.addSubview(webView)
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
        
        self.webView.load(self.viewModel.getUrl())
        
    }
}
