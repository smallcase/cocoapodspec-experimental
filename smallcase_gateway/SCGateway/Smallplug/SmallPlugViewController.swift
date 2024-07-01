//
//  SmallPlugViewController.swift
//  SCGateway
//
//  Created by Ankit Deshmukh on 22/06/21.
//  Copyright © 2021 smallcase. All rights reserved.
//

import UIKit
import WebKit
import SafariServices

class SmallPlugViewController: UIViewController, WKUIDelegate {
    
    //MARK: Variables
    
    private var showSmallcaseLoader: Bool
    
    internal var webViewAnimated = false
    
    enum MessageHandlers {
        static let smallplugNativeTransaction = "smallplugNativeTransaction"
        static let smallplugHandleIntent = "smallplugHandleIntent"
        static let getInitInfo = "getInitInfo"
        static let closeSmallplug = "closeSmallplug"
    }
    
    internal var viewModel: SmallplugViewModelProtocol!
    
    //MARK: UI Variables
    
    // Shows smallcase loading Icon
    fileprivate lazy var smallcaseLoaderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.loadGif(name: "smallcase-loader")
        return imageView
    }()
    
    fileprivate lazy var smallplugHeader = SmallplugHeader()
    
    internal let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var webView: WKWebView = {
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(self, name: MessageHandlers.smallplugNativeTransaction)
        configuration.userContentController.add(self, name: MessageHandlers.smallplugHandleIntent)
        configuration.userContentController.add(self, name: MessageHandlers.getInitInfo)
        configuration.userContentController.add(self, name: MessageHandlers.closeSmallplug)
        configuration.allowsInlineMediaPlayback = true
        configuration.allowsPictureInPictureMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        configuration.preferences = preferences
        
        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.backgroundColor = .clear
        webView.backgroundColor = .clear
        webView.layer.cornerRadius = 11.8
        webView.clipsToBounds = true
        
        return webView
        
    }()
    
    let spinner = UIActivityIndicatorView(style: .whiteLarge)
    
    //MARK: Init
    
    init(showSmallcaseLoader: Bool, viewModel: SmallplugViewModelProtocol) {
        
        self.showSmallcaseLoader = showSmallcaseLoader
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
    }
    
    func setupUI() {
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)
        spinner.centerInSuperview()
        
        //        smallplugHeader = SmallplugHeader(backIconColor: viewModel.backIconColor, backIconColorOpacity: viewModel.backIconColorOpacity)
        
        self.view.addSubview(containerView)
        containerView.addSubview(smallplugHeader)
        
        smallplugHeader.dmUiConfig = viewModel.uiConfig
        
        //        smallplugHeader.backIconColor = viewModel.backIconColor
        //        smallplugHeader.backIconColorOpacity = viewModel.backIconColorOpacity
        
        self.view.addSubview(webView)
        
        //        self.view.addSubview(smallplugLoader.withSize(.init(width: self.view.bounds.width, height: 300)))
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        
        //        NSLayoutConstraint.activate([
        //            smallplugLoader.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        //        ])
        
        containerView.anchor(
            self.view.safeAreaLayoutGuide.topAnchor,
            left: self.view.safeAreaLayoutGuide.leftAnchor,
            bottom: self.webView.topAnchor,
            right: nil,
            topConstant: 0,
            leftConstant: 0,
            bottomConstant: 5,
            rightConstant: 0,
            widthConstant: 135,
            heightConstant: 30
        )
        
        //        self.view.addSubview(smallcaseLoaderImageView.withSize(.init(width: 127, height: 80)))
        //        smallcaseLoaderImageView.centerInSuperview()
        
        if !self.showSmallcaseLoader {
            //            smallcaseLoaderImageView.isHidden = true
            //            smallplugLoader.isHidden = true
        }
        
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: self.containerView.bottomAnchor),
            webView.leftAnchor
                .constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
            webView.bottomAnchor.constraint(equalToSystemSpacingBelow: self.view.bottomAnchor, multiplier: 1.0),
            webView.rightAnchor
                .constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor)
        ])
        
        containerView.alpha = 0
        webView.alpha = 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.initWebView()
        })
        
        let recognizer = UITapGestureRecognizer(target:self, action: #selector(didTapDismiss))
        containerView.addGestureRecognizer(recognizer)
    }
    
    func initWebView() {
        
        webView.load(viewModel.getSmallplugLaunchURL())
    }
    
    
    
    @objc func didTapDismiss() {
        UIView.animateKeyframes(withDuration: 0.3, delay: 0, options: [.calculationModeCubic], animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.3, animations: {
                self.view.frame.origin.y += 32
            })
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.3, animations: {
                self.view.alpha = 0
            })
        }, completion:{ _ in
            self.viewModel.dismissSmallPlug()
        })
        
    }
}

