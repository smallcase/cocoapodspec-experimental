//
//  ScLoadingViewControllerAsync.swift
//  SCGateway
//
//  Created by Indrajit Roy on 07/12/23.
//  Copyright © 2023 smallcase. All rights reserved.
//

import Foundation

class ScLoadingViewController: UIViewController {
    
    required init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.isOpaque = false
        view.backgroundColor = UIColor.init(white: 0, alpha: 0.8)
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.loadGif(name: Constants.loaderImageGifName)
        imageView.isHidden = false
        view.addSubview(imageView.withSize(.init(width: 127, height: 80)))
        imageView.centerInSuperview()
    }
}
