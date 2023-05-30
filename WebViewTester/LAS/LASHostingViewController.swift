//
//  LASHostingViewController.swift
//  WebViewTester
//
//  Created by Ankit Deshmukh on 14/05/23.
//  Copyright © 2023 smallcase. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

@available(iOS 13.0, *)
struct LASHostingViewControllerRepresentable: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController
    
    func makeUIViewController(context: Context) -> UIViewController {
        // Create and return your custom UIViewController here
        return LASHostingViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Perform any necessary updates to the UIViewController
    }
}

class LASHostingViewController: UIViewController {
    // Your custom view controller implementation
    // ...
}
