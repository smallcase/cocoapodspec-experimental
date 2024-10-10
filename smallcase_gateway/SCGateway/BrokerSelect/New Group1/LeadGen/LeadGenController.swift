//
//  LeadGenController.swift
//  SCGateway
//
//  Created by Dip on 10/08/20.
//  Copyright © 2020 smallcase. All rights reserved.
//

import Foundation
import WebKit


protocol LeadGenControllerDelegate: AnyObject {
    func dismissLeadGen()
    func dismissLeadGen(_ leadStatus: [String: Any]?)
}


class LeadGenController: UIViewController,
                         WKUIDelegate,
                         WKNavigationDelegate,
                         WKScriptMessageHandler {
    
    
    enum MessageHandlers {
        static let closeWebView = "closeWebView"
        static let openThirdPartyUrl = "openThirdPartyUrl"
        static let openThirdPartyUrlWithData = "openThirdPartyUrlWithData"
        static let openPwaWithData = "openPwaWithData"
        static let openPwa = "openPwa"
    }
    
    //MARK: - Variables
    weak var delegate:LeadGenControllerDelegate?
    
    lazy var webView: WKWebView = {
        let contentController = WKUserContentController()
        contentController.add(self, name: MessageHandlers.closeWebView)
        contentController.add(self, name: MessageHandlers.openThirdPartyUrl)
        contentController.add(self, name: MessageHandlers.openThirdPartyUrlWithData)
        contentController.add(self, name: MessageHandlers.openPwa)
        contentController.add(self, name: MessageHandlers.openPwaWithData)
        
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
    fileprivate lazy var smallcaseLoaderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.loadGif(name: "smallcase-loader")
        return imageView
    }()
    
    var params : Dictionary<String,String>?
    var utmParams: Dictionary<String,String>?
    var retargeting: Bool?
    var loadedUrl:URL?
    var showLoader: Bool
    var showLoginCta: Bool?
    
    var leadGenCompletion: ((String?) -> Void)?
    
    var leadStatus: [String: Any]?
    
    // MARK: - Initialise
    init(params:Dictionary<String,String>?, showLoader: Bool, leadGenUtmParams: Dictionary<String, String>?, isRetargeting: Bool?) {
        self.params = params
        self.utmParams = leadGenUtmParams
        self.retargeting = isRetargeting
        self.showLoader = showLoader
        super.init(nibName: nil, bundle: nil)
    }
    
    // With Lead Status response
    init(params: Dictionary<String,String>?,
         showLoader: Bool,
         leadGenUtmParams: Dictionary<String, String>?,
         isRetargeting: Bool?,
         leadGenCompletion: ((String?) -> Void)?
    ) {
        self.params = params
        self.utmParams = leadGenUtmParams
        self.retargeting = isRetargeting
        self.showLoader = showLoader
        self.leadGenCompletion = leadGenCompletion
        super.init(nibName: nil, bundle: nil)
    }
    
    init(params: Dictionary<String,String>?,
         showLoader: Bool,
         leadGenUtmParams: Dictionary<String, String>?,
         isRetargeting: Bool?,
         showLoginCta: Bool?,
         leadGenCompletion: ((String?) -> Void)?
    ) {
        self.params = params
        self.utmParams = leadGenUtmParams
        self.retargeting = isRetargeting
        self.showLoader = showLoader
        self.showLoginCta = showLoginCta
        self.leadGenCompletion = leadGenCompletion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadWebViewUrl()
    }
    
    // MARK: Load url in webview
    private func loadWebViewUrl(){
        print("version = \(SCGateway.shared.getSdkVersion())")
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        switch SessionManager.baseEnvironment {
        case .development:
            urlComponents.host = "dev.smallcase.com"
        case .staging:
            urlComponents.host = "stag.smallcase.com"
        default:
            urlComponents.host = "www.smallcase.com"
        }
        
        urlComponents.path = "/gateway-signup"
        
        var queryItems = [
            URLQueryItem(name: "deviceType", value: "ios"),
            URLQueryItem(name: "showCloseBtn", value: "true"),
            URLQueryItem(name: "gateway", value: SessionManager.gatewayName),
            URLQueryItem(name: "v", value: SCGateway.shared.getSdkVersion())
        ]
        
        if let queryParams = self.params {
            for (key,value) in queryParams {
                queryItems.append(URLQueryItem(name: key, value: value))
            }
        }
        
        if let utmParameters = self.utmParams {
            for (key,value) in utmParameters {
                queryItems.append(URLQueryItem(name: key, value: value))
            }
        }
        
        if let isRedirecting = self.retargeting {
            queryItems.append(URLQueryItem(name: "retargeting", value: isRedirecting.description))
        }
        
        if let showLoginCta = self.showLoginCta {
            queryItems.append(URLQueryItem(name: "showLoginBtn", value: showLoginCta.description))
        }
        
        urlComponents.queryItems = queryItems
        
        let myRequest = URLRequest(url: urlComponents.url!)
        webView.load(myRequest)
        loadedUrl = urlComponents.url
       
    }
    
    
    func setupUI() {
        self.view.addSubview(smallcaseLoaderImageView.withSize(.init(width: 127, height: 80)))
        smallcaseLoaderImageView.centerInSuperview()
//        self.view.backgroundColor = UIColor.init(white: 0, alpha: 0.8)
        self.view.addSubview(webView)
        
        if !self.showLoader {
            self.smallcaseLoaderImageView.isHidden = true
        }
        
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
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard
            let url = navigationAction.request.url,
            let scheme = url.scheme else {
                decisionHandler(.cancel)
                return
        }
        
        if ((scheme.lowercased() == "mailto" || scheme.lowercased() == "tel" || scheme.lowercased() == "http" || scheme.lowercased() == "https") && url != loadedUrl && !url.absoluteString.contains("https://vars.hotjar.com")) {
            print(url)
//            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            // here I decide to .cancel, do as you wish
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
    
    // MARK: Handling bridge methods
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        switch message.name {
            case MessageHandlers.openThirdPartyUrl:
            
            UIApplication.shared.open(URL(string: message.body as! String)!, options: [:], completionHandler: {_ in
                self.dismiss(animated: false, completion: nil)
                self.delegate?.dismissLeadGen()
            })
            
        case MessageHandlers.openThirdPartyUrlWithData, MessageHandlers.openPwaWithData:
                
                if let messageBody = message.body as? String {
                    
                    let data = Data(messageBody.utf8)
                    
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            
                            if let launchURL = json["url"] as? String, let leadData = json["data"] as? [String: Any] {
                                
                                UIApplication.shared.open(URL(string: launchURL)!, options: [:], completionHandler: {_ in
                                    
                                    let jsonData = (try? JSONSerialization.data(withJSONObject: leadData, options: [.prettyPrinted]))!
                                    
                                    let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)!
                                    
                                    if self.leadGenCompletion != nil {
                                        self.dismiss(animated: false, completion: nil)
                                        self.leadGenCompletion!(jsonString)
                                    } else {
                                        self.dismiss(animated: false, completion: nil)
                                        self.delegate?.dismissLeadGen(leadData)
                                    }
                                })
                                
                            }
                            
                        }
                    } catch let error as NSError {
                        print("Failed to convert message body to json: \(error.localizedDescription)")
                    }
                    
                }
            case MessageHandlers.openPwa:
            
                if let jsonString = message.body as? String {
                    let data: Data = jsonString.data(using: .utf8)!
                
                    do {
                        let jsonObject = try JSONSerialization.jsonObject(with: data, options: .init(rawValue: 0))
                    
                        if let jsonObjDict = jsonObject as? [String: String] {
                            
                    }
                } catch {
                    print("Error opening PWA flow")
                }
            }
        
            case MessageHandlers.closeWebView:
//                print("LeadGenController: closeWebView \(message.body)")

                if let leadStatus = message.body as? String {
                    
                    self.dismiss(animated: false, completion: nil)
                    
                    if self.leadGenCompletion != nil {
                        self.leadGenCompletion!(leadStatus)
                    } else {
                        delegate?.dismissLeadGen(leadStatus.toDictionary)
                    }
                } else {
                    delegate?.dismissLeadGen()
                }
                
        default:
            print(message.name)
            print(message.body)
//            self.dismiss(animated: false, completion: nil)
//            delegate?.dismissLeadGen()
            
        }
    }
    
    //MARK: Dismiss Webview
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.dismiss(animated: false, completion: nil)
        delegate?.dismissLeadGen()
    }
    
}
