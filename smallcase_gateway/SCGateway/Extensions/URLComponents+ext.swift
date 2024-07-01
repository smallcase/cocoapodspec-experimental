//
//  URLComponents+ext.swift
//  SCGateway
//
//  Created by Shivani on 06/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation
/**
 - This extension will merge baseURL with path and will add parameters to the url if parameters encoding is url.
 */

extension URLComponents {
    init(service: ServiceProtocol) {
        let url = service.baseURL.appendingPathComponent(service.path)
        self.init(url: url, resolvingAgainstBaseURL: false)!
        
        guard case let .requestParameters(parameters) = service.task, service.parameterEncoding == .url else {
            return
        }
        
        // If parameters encoding is “url” and request has parameters — create array of [URLQueryItem] for each parameter and set to the queryItems.
        queryItems = parameters.map{ key, value in
            return URLQueryItem(name: key, value: String(describing: value))
        }
    }
}
