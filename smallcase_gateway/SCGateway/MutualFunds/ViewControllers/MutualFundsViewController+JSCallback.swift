//
//  MutualFundsViewController+JSCallback.swift
//  SCGateway
//
//  Created by Indrajit Roy on 21/09/22.
//  Copyright © 2022 smallcase. All rights reserved.
//

import Foundation
import WebKit

extension MFViewController : WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("MFViewController: JSCallback enter -> \(message.name) \(message.body)")
        if message.name == MessageHandlers.dispatch {
            if let messageBody = message.body as? String {
                print("MFViewController: JSCallback messageBody -> \(messageBody)")
                viewModel.processDispatchMessage(message: messageBody)
            }
        } else {
            print("MFViewController: JSCallback -> \(message.name)")
        }
    }
}

extension MFViewController : WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    }
}
