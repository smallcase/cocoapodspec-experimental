//
//  SmallplugViewModel.swift
//  SCGateway
//
//  Created by Ankit Deshmukh on 28/07/21.
//  Copyright © 2021 smallcase. All rights reserved.
//

import UIKit

class SmallplugViewModel: NSObject, SmallplugViewModelProtocol {
    
    var uiConfig: SmallplugUiConfig?
    
    var headerColor: String? = nil
    var backIconColor: String? = nil
    var headerColorOpacity: CGFloat? = nil
    var backIconColorOpacity: CGFloat? = nil
    
    internal weak var smallplugCoordinatorDelegate: SmallplugCoordinatorVMDelegate?
    
    init(smallplugUiConfig: SmallplugUiConfig?) {
        self.uiConfig = smallplugUiConfig
    }
    
    override init() {
        
    }
    
    func dismissSmallPlug() {
        self.smallplugCoordinatorDelegate?.smallplugFinished()
    }
    
    func getSmallplugLaunchURL() -> URLRequest {
        var urlComponents = URLComponents()
        
        urlComponents.scheme = "https"
        urlComponents.host = "\(SessionManager.gatewayName!).smallcase.com"
        
//        urlComponents.path = "/"
        
        if let smallplugPath = SessionManager.smallplugTargetEndpoint {
            
            let paths = smallplugPath.split(separator: "/")
            
            for route in paths {
                urlComponents.path.append("/" + route.description)
            }
//            urlComponents.path = "/\(smallplugPath)"
        } else {
            urlComponents.path = "/"
        }
        
        let queryItems = [
            URLQueryItem(name: "ct", value: "smallplug_ios"),
        ]
        
        urlComponents.queryItems = queryItems
        
        if let queryParams = SessionManager.smallplugUrlParams {
            urlComponents.query?.append("&"+queryParams)
        }
        
        print(urlComponents.url ?? "")
        
        return URLRequest(url: urlComponents.url!)
    }
    
    func isUrlValidForLaunch(_ absoluteUrlString: String) -> Bool {
        
        for urlString in Constants.invalidURLs {
            if absoluteUrlString.contains(urlString) {
                return false
            }
        }
        
        return true
    }
}
