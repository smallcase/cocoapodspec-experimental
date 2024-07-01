//
//  SmallplugViewController+WebView.swift
//  SCGateway
//
//  Created by Ankit Deshmukh on 03/06/22.
//  Copyright © 2022 smallcase. All rights reserved.
//

import Foundation
import WebKit
import SafariServices

extension SmallPlugViewController: WKNavigationDelegate {
    
    //MARK: Webview overriden methods
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

        if let uiConfig = self.viewModel.uiConfig {
            self.view.backgroundColor = UIColor.init(hex: uiConfig.headerColor ?? "2685EF", alpha: uiConfig.opacity ?? 1.0)
        } else {
            self.view.backgroundColor = UIColor.init(hex: "2685EF", alpha: 1.0)
        }
        
        if(!self.webViewAnimated) {
            
            self.webViewAnimated = true
            
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           usingSpringWithDamping: 1.0,
                           initialSpringVelocity: 1.0,
                           options: .transitionCurlUp, animations: {
                
                self.containerView.alpha = 1
                webView.alpha = 1
                
                if #available(iOS 13, *) {
                    
                    self.containerView.frame = CGRect(x: 0, y: 0, width: self.containerView.bounds.size.width, height: UIScreen.main.bounds.size.height - self.containerView.bounds.size.height)
                    
                    self.webView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: self.webView.bounds.size.height)
                } else {
                    
                    self.containerView.frame = CGRect(x: 0, y: 0, width: self.containerView.bounds.size.width, height: self.containerView.bounds.size.height + 35)
                    
                    self.webView.frame = CGRect(x: 0, y: 35 + self.view.safeAreaInsets.top, width: UIScreen.main.bounds.size.width, height: self.webView.bounds.size.height)
                    
                }
                
            }, completion: nil)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let url = navigationAction.request.url, let scheme = url.scheme else {
            decisionHandler(.cancel)
            return
        }
        
        if ((scheme.lowercased() == "mailto" || scheme.lowercased() == "tel")  && self.viewModel.isUrlValidForLaunch(url.absoluteString)) {
            print(url)
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
            decisionHandler(.cancel)
            return
        }
        
        if !url.absoluteString.contains(SessionManager.gatewayName!) && self.viewModel.isUrlValidForLaunch(url.absoluteString) {
            
            print("launching: \(url.absoluteString) from smallplug")
            
            let safariVC = SFSafariViewController(url: url)
            self.present(safariVC, animated: true, completion: nil)
            
            if url.pathExtension == "csv" {
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
            
            return
        }
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        guard let url = navigationAction.request.url, let _ = url.scheme else {
            return nil
        }
        
        if !url.absoluteString.contains(SessionManager.gatewayName!) && self.viewModel.isUrlValidForLaunch(url.absoluteString) {
            
            print("launching: \(url.absoluteString) from smallplug")
            
            let safariVC = SFSafariViewController(url: url)
            self.present(safariVC, animated: true, completion: nil)
        }
        
        return nil
    }
}
