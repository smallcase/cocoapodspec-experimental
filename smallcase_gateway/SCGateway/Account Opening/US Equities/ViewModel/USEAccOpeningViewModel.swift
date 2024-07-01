//
//  USEAccOpeningViewModel.swift
//  SCGateway
//
//  Created by Ankit Deshmukh on 17/10/22.
//  Copyright © 2022 smallcase. All rights reserved.
//

import Foundation
import AuthenticationServices

class USEAccOpeningViewModel: NSObject, USEAccOpeningViewModelProtocol {
    
    //MARK: Variables
    var signUpConfig: SignUpConfig? = nil
    var additionalConfig: [String: Any]? = nil
    
    // Wrappers for web auth session
    internal var webAuthProvider: WebAuthenticationProvider!
    internal lazy var gatewayAuthProvider: Any? = nil
    
    internal lazy var webPresentationContextProvider: Any? = nil
    
    internal weak var coordinatorDelegate: USEAccOpeningCoordinatorVMDelegate?
    
    //MARK: Init
    init(_ signUpConfig: SignUpConfig?, _ additionalConfig: [String: Any]?) {
        self.signUpConfig = signUpConfig
        self.additionalConfig = additionalConfig
    }
    
    init(_ signUpConfig: SignUpConfig?) {
        self.signUpConfig = signUpConfig
    }
    
    override init() {
        self.signUpConfig = nil
    }
    
    private func getUSEAccOpeningUrl() -> URL {
        
        var useAccOpeningUrlComponent = URLComponents()
        useAccOpeningUrlComponent.scheme = "https"
        useAccOpeningUrlComponent.host = "onboarding-dev.use.smallcase.com"
        
        if let mobileConfig = SessionManager.mobileConfig,
           let accountOpeningJson = mobileConfig["accountOpening"] as? [String: String],
           let launchUrl = accountOpeningJson["launchURL"] {
            useAccOpeningUrlComponent.host = launchUrl.deletingPrefix("https://")
        }
        
        useAccOpeningUrlComponent.path = "/accounts"
        
        var queryItems = [
            URLQueryItem(name: "deviceType", value: "ios"),
            URLQueryItem(name: "gateway", value: SessionManager.gatewayName),
            URLQueryItem(name: "v", value: SCGateway.shared.getSdkVersion())
        ]
        
        if let additionalConfig = self.additionalConfig {
            for (key, value) in additionalConfig {
                queryItems.append(URLQueryItem(name: key, value: (value as! String)))
            }
        }
        
        if let opaqueId = self.signUpConfig?.opaqueId {
            queryItems.append(URLQueryItem(name: "opaqueId", value: opaqueId))
        }
        
        if let userInfo = self.signUpConfig?.userInfo {
            queryItems.append(URLQueryItem(name: "userId", value: userInfo.userId))
            queryItems.append(URLQueryItem(name: "idType", value: userInfo.idType))
        }
        
        if let utmParams = self.signUpConfig?.utmParams {
            
            if let utmCampaign = utmParams.utmCampaign {
                queryItems.append(URLQueryItem(name: "utmCampaign", value: utmCampaign))
            }
            
            if let utmContent = utmParams.utmContent {
                queryItems.append(URLQueryItem(name: "utmContent", value: utmContent))
            }
            
            if let utmMedium = utmParams.utmMedium {
                queryItems.append(URLQueryItem(name: "utmMedium", value: utmMedium))
            }
            
            if let utmSource = utmParams.utmSource {
                queryItems.append(URLQueryItem(name: "utmSource", value: utmSource))
            }
            
            if let utmTerm = utmParams.utmTerm {
                queryItems.append(URLQueryItem(name: "utmTerm", value: utmTerm))
            }
            
        }
        
        if let retargeting = self.signUpConfig?.retargeting {
            queryItems.append(URLQueryItem(name: "retargeting", value: retargeting.description))
        }
        
        useAccOpeningUrlComponent.queryItems = queryItems
        
        print("USE account opening URL: \(String(describing: useAccOpeningUrlComponent.url?.debugDescription))")
        
        return useAccOpeningUrlComponent.url!
    }
    
    //MARK: Launch Custom Tab
    internal func launchCustomTab() {
        
        if #available(iOS 13.0, *) {
            
            webAuthProvider = nil
            
            gatewayAuthProvider = GatewayAuthenticationProvider(
                url: getUSEAccOpeningUrl(),
                callbackURLScheme: USEAccountOpeningConstants.callbackUrlScheme,
                presentationContextProvider: webPresentationContextProvider as? ASWebAuthenticationPresentationContextProviding,
                completionHandler: { [weak self] (url, err) in
                    self?.handleSuccessOrErrorCompletion(url, err)
                })
            
            if let gatewayAuthProvider = self.gatewayAuthProvider as? GatewayAuthenticationProvider, gatewayAuthProvider.start() {
                print("-------------------- Started USE Account Opening Custom Tab --------------------------")
            }
            
        } else {
            
            webAuthProvider = WebAuthenticationProvider(
                url: getUSEAccOpeningUrl(),
                callbackURLScheme: USEAccountOpeningConstants.callbackUrlScheme,
                completionHandler: { [weak self] (url, err) in
                    self?.handleSuccessOrErrorCompletion(url, err)
                })
            
            if webAuthProvider.start() {
                print("-------------------- Started USE Account Opening Custom Tab --------------------------")
            }
        }
    }
    
    
    private func handleSuccessOrErrorCompletion(_ url: URL?,_ error: Error?) {
        
        SCGateway.shared.fetchLeadStatus(leadId: url?.valueOfQueryParam("leadId"), opaqueId: self.signUpConfig?.opaqueId)
        
    }

}
