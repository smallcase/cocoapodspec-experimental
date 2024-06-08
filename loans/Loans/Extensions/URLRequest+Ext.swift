//
//  URLRequest+Ext.swift
//  Loans
//
//  Created by Ankit Deshmukh on 06/05/23.
//

import Foundation

extension URLRequest {
    
    init(service: ServiceProtocol) {
        let urlComponents = URLComponents(service: service)
        
        self.init(url: urlComponents.url!)
        
        httpMethod = service.method.rawValue
        
        service.headers?.forEach{ key, value in
            addValue(value, forHTTPHeaderField: key)
        }
        
        //If parameters encoding is “json” and request has parameters — use JSONSerialization to covert dictionary with parameters to Data.
        guard case let .requestParameters(parameters) = service.task, service.parameterEncoding == .body else  {
            return
        }
        
        httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
    }
}
