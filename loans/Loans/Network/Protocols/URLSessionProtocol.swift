//
//  URLSessionProtocol.swift
//  Loans
//
//  Created by Ankit Deshmukh on 06/05/23.
//

import Foundation

protocol URLSessionProtocol {
    typealias DataTaskResult = (Data?, URLResponse?, Error?) -> ()
    
    func dataTask(request: URLRequest, completionHandler: @escaping DataTaskResult ) -> URLSessionDataTask
}


extension URLSession: URLSessionProtocol {
    
    func dataTask(request: URLRequest, completionHandler: @escaping DataTaskResult ) -> URLSessionDataTask {
        return dataTask(with: request, completionHandler: completionHandler)
        
    }
}
