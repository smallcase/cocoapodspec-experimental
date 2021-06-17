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
            
//            let popupDialogVc = CustomPopupViewController(nibName: "CustomPopupViewController", bundle: nil);
            
//            let popupDialog = PopupDialog(title: title, message: msg, buttonAlignment: .horizontal)
////            let popupDialog = PopupDialog(viewController: popupDialogVc, buttonAlignment: .horizontal)
//
//            let copyBtn = DefaultButton(title: "Copy", dismissOnTap: false) {
//                UIPasteboard.general.string = msg
//            }
//
//            let okBtn = DefaultButton(title: "Ok", dismissOnTap: true, action: nil)
//
//            let dialogAppearance = PopupDialogDefaultView.appearance()
//            dialogAppearance.backgroundColor      = .white
//            dialogAppearance.titleFont            = .boldSystemFont(ofSize: 14)
//            dialogAppearance.titleColor           = UIColor(white: 0.4, alpha: 1)
//            dialogAppearance.titleTextAlignment   = .center
//            dialogAppearance.messageFont          = .systemFont(ofSize: 12)
//            dialogAppearance.messageColor         = UIColor(white: 0.6, alpha: 1)
//            dialogAppearance.messageTextAlignment = .center
//            dialogAppearance.autoresizesSubviews = true
//
//            popupDialog.addButtons([copyBtn, okBtn])
//
//            self?.present(popupDialog, animated: true, completion: nil)
            
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


