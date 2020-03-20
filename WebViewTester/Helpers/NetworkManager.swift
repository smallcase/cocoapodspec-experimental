//
//  NetworkManager.swift
//  WebViewTester
//
//  Created by Shivani on 21/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation
import SCGateway


enum HTTPRequest {
    static let get = "GET"
    static let post = "POST"
}

enum NetworkError: Error {
    case invalidUrl
    case noData
    case parsingError
    case invalidParams
}

//let BASE_URL = "https://api.dev.smartinvesting.io"
var ENVIRONMENT: Environment!

class NetworkManager {
    
    static let shared = NetworkManager()
    
    let session = URLSession.shared

    func getBaseUrl() -> String {
        switch ENVIRONMENT {
        case .staging:
            return "https://api.stag.smartinvesting.io"
        case .development:
            return "https://api.dev.smartinvesting.io"
        default:
            return "https://api.smartinvesting.io"
        }
    }
    
    func getAuthToken(username: String, completion: @escaping(Result<GetAuthTokenResponse, NetworkError>) -> Void )  {
        
        let urlString = "\(getBaseUrl())/user/login"
        let params: [String: Any] = ["id": username]
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidUrl))
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = HTTPRequest.post
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return
        }
        urlRequest.httpBody = httpBody
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(GetAuthTokenResponse.self, from: data)
                print("DECODED DATA")
                print(decodedData)
                completion(.success(decodedData))
            }
            catch let err {
                print(err)
                completion(.failure(NetworkError.parsingError))
            }
        }
       
        task.resume()
    }
    
    func getTransactionId(params: CreateTransactionBody, completion: @escaping (Result<CreateTransactionResponse, Error>) -> Void) {
        
        let urlString = "\(getBaseUrl())/transaction/new"
        
        guard let url = URL(string: urlString) else { return }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let body =  try JSONEncoder().encode(params)
            print( "TRANSACTION BODY: \(body)")
            urlRequest.httpBody = body
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            print(String(data: body, encoding: .utf8) ?? "Trx body nil")
            
            let task = session.dataTask(with: urlRequest) { (data, response, error) in
                guard let data = data else {
                    completion(.failure(NetworkError.noData))
                    return
                }
                do {
                    let decodedData = try JSONDecoder().decode(CreateTransactionResponse.self, from: data)
                    print(decodedData)
                    completion(.success(decodedData))
                    
                }
                catch let err {
                    
                    print(err)
                    completion(.failure(NetworkError.parsingError))
                }
            }
            
            task.resume()
            
        }
        catch let err {
            print("JSON DECODE ERROR: \(err)")
        }
    }
    
    func connectBroker(userId: String, authToken: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        
        let params = [
            "id": userId,
            "smallcaseAuthToken": authToken
        ]
        
        let urlComponents = URLComponents(string: "\(getBaseUrl())/user/connect")
        
        var urlRequest = URLRequest(url: urlComponents!.url!)
        urlRequest.httpMethod = HTTPRequest.post
        do {
            urlRequest.httpBody =  try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            print(String(data: urlRequest.httpBody!, encoding: .utf8) ?? "")
        }
        catch let error {
            print(error)
            
        }
        
        
        
        
        print("CONNECT URL: \(urlRequest.description)")
        let task = session.dataTask(with: urlRequest) { (data, response, error) in
            guard data != nil else {
                completion(.failure(NetworkError.noData))
                return
            }
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            print(String(data: data!, encoding: .utf8) ?? "")
            completion(.success(true))
            
        }
   
        task.resume()
            
    }
    
    
    private init() {}
}
