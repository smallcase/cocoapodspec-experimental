//
//  URLSessionProtocol .swift
//  SCGateway
//
//  Created by Shivani on 06/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//


protocol URLSessionProtocol {
    typealias DataTaskResult = (Data?, URLResponse?, Error?) -> ()
    
    func dataTask(request: URLRequest, completionHandler: @escaping DataTaskResult ) -> URLSessionDataTask
}


extension URLSession: URLSessionProtocol {
    
    func dataTask(request: URLRequest, completionHandler: @escaping DataTaskResult ) -> URLSessionDataTask {
        return dataTask(with: request, completionHandler: completionHandler)
        
    }
}
