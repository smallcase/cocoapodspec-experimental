//
//  LoadingScreenViewController.swift
//  Loans
//
//  Created by Ankit Deshmukh on 04/05/23.
//

import UIKit
import AuthenticationServices

class LoadingScreenViewController: UIViewController {

    //MARK: Variables
    var viewModel: LASViewModelProtocol? = nil
    
    //MARK: Sub-Views
    fileprivate lazy var loadingView: LoadingScreenView = {
        let view = LoadingScreenView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.viewModel = self.viewModel
        return view
    }()
    
    /// Shows smallcase loading Icon
    fileprivate lazy var smallcaseLoaderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.loadGif(name: "smallcase-loader")
        return imageView
    }()
    
    init(_ viewModel: LASViewModelProtocol) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        self.viewModel?.viewControllerDelegate = self
        
        if #available(iOS 13.0, *) {
            self.viewModel?.webPresentationContextProvider = self
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        self.viewModel?.authenticateInteraction()
    }


    private func setupUI() {
        view.isOpaque = false
        view.backgroundColor = UIColor.init(white: 0, alpha: 0.8)
        
        ///add subviews
        self.view.addSubview(smallcaseLoaderImageView.withSize(.init(width: 127, height: 80)))
        self.view.addSubview(loadingView.withSize(.init(width: view.bounds.width - 32, height: 178)))
        
        ///View Constraints
        smallcaseLoaderImageView.centerInSuperview()
        loadingView.centerInSuperview()
        
        ///initially the loading view is hidden
        loadingView.isHidden = true
    }

}

extension LoadingScreenViewController: ViewModelUIViewControllerDelegate {
    
    func updateState(showLoadingView: Bool) {
            DispatchQueue.main.async {
                self.smallcaseLoaderImageView.isHidden = showLoadingView
                self.loadingView.isHidden = !showLoadingView
                self.loadingView.updateUi()
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(SessionManager.gatewayIosConfig?.uiConfig.loansLoader.duration ?? 3000)) { [weak self] in
                    self?.viewModel?.launchLOSJourney()
                }
            }
        
    }
}

//MARK: WebAuth Presentation Context Provider
extension LoadingScreenViewController: ASWebAuthenticationPresentationContextProviding {
    @available(iOS 13.0, *)
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.keyWindow!.windowScene else { fatalError("No Key Window Scene")}
        return ASPresentationAnchor(windowScene: windowScene )
    }
}
