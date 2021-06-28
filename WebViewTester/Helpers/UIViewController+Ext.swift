//
//  UIViewController+Ext.swift
//  WebViewTester
//
//  Created by Shivani on 09/03/20.
//  Copyright © 2020 smallcase. All rights reserved.
//

import UIKit
import PopupDialog

extension UIViewController {
    
    func showPopup(title: String? , msg: String?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            
            let alertController = UIAlertController(title: title, message: msg, preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Copy", style: .default) { (action) in
                UIPasteboard.general.string = msg
            }
            
            alertController.addAction(cancelAction)
            
            let destroyAction = UIAlertAction(title: "Ok", style: .default)
            
            alertController.addAction(destroyAction)
            
            self?.present(alertController, animated: true, completion: nil)
        }
    }
}


