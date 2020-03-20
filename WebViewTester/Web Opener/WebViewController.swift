//
//  WebViewController.swift
//  WebViewTester
//
//  Created by Shivani on 06/06/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    @IBOutlet weak var webViewContainer: UIView!
    var urlString: String?
    
    var webView: WKWebView!
    
    var popupWebView: WKWebView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        
        webView = WKWebView(frame: webViewContainer.bounds, configuration: configuration)
        //  webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.clipsToBounds = true
        //   webView.contentMode = .scaleAspectFit
        
        // webView.scalesPageToFit = TRUE;
        
        webViewContainer.addSubview(webView)
        
        
        if let urlStr = urlString, let url = URL(string: urlStr)  {
            webView.load(URLRequest(url: url))
            webView.allowsBackForwardNavigationGestures = true
        }
        
        // Do any additional setup after loading the view.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}


extension WebViewController: WKNavigationDelegate, WKUIDelegate {
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        //let popupViewFrame = CGRect(x: view.center.x - 150, y: view.center.y/2, width: 360, height: 400)
        popupWebView = WKWebView(frame: webView.bounds, configuration: configuration)
        
        popupWebView?.uiDelegate = self
       // popupWebView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      
        popupWebView?.navigationDelegate = self
        popupWebView?.clipsToBounds = true
        webView.addSubview(popupWebView!)
       
        return popupWebView!
    }
    
    
    func webViewDidClose(_ webView: WKWebView) {
        
        if webView == popupWebView {
            popupWebView?.removeFromSuperview()
            popupWebView = nil
        }
    }
}

