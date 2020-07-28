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
                   let popupDialog = PopupDialog(title: title, message: msg)
                   self?.present(popupDialog, animated: true, completion: nil)
               }
    }
}


