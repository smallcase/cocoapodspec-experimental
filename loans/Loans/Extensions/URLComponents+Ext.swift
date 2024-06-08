//
//  URLComponents+Ext.swift
//  Loans
//
//  Created by Ankit Deshmukh on 06/05/23.
//

import Foundation

/**
 - This extension will merge baseURL with path and will add parameters to the url if parameters encoding is url.
 */

extension URLComponents {
    init(service: ServiceProtocol) {
        var url = service.baseURL
        
        if let path = service.path {
            url = service.baseURL.appendingPathComponent(path)
        }
        self.init(url: url, resolvingAgainstBaseURL: false)!
        
        guard case let .requestParameters(parameters) = service.task, service.parameterEncoding == .query else {
            return
        }
        
        // If parameters encoding is “url” and request has parameters — create array of [URLQueryItem] for each parameter and set to the queryItems.
        queryItems = parameters.map{ key, value in
            return URLQueryItem(name: key, value: String(describing: value))
        }
    }
}
