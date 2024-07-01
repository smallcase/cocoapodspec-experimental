//
//  URLRequest+ext.swift
//  SCGateway
//
//  Created by Shivani on 06/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
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
        guard case let .requestParameters(parameters) = service.task, service.parameterEncoding == .json else  {
            return
        }
        
        httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
    }
}
