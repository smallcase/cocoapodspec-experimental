//
//  UnityApi.swift
//  WebViewTester
//
//  Created by Ankit Deshmukh on 25/05/23.
//  Copyright © 2023 smallcase. All rights reserved.
//

import Foundation
import Loans

extension SmartinvestingApi {
    
    func createUser(completion: @escaping (Result<Data, Error>) -> Void) {
        
        let urlString = "\(getLASBaseUrl())/las/user"
        
        guard let url = URL(string: urlString) else { return }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.cachePolicy = .reloadRevalidatingCacheData
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let params = CreateUser(pan: LASSessionManager.pan, dob: LASSessionManager.dob, id: LASSessionManager.userId, lender: LASSessionManager.lender)
        
        do {
            let body =  try JSONEncoder().encode(params)
            print( "Create User Body: \(body)")
            
            urlRequest.httpBody = body
            
            print(String(data: body, encoding: .utf8) ?? "Create user body nil")
            
            print("API Request -------------->")
            print(urlRequest)
            
            let task = session.dataTask(with: urlRequest) { (data, response, error) in
                guard let data = data else {
                    completion(.failure(NetworkError.noData))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else { completion(.failure(NetworkError.noData))
                    return
                }
                
                print("------> Http response code: \(httpResponse.statusCode)")
                
                switch httpResponse.statusCode {
                    case 200...299:
                        print("API RESPONSE ------------------>")
                        // Convert to a string and print
                        print(String(data: data, encoding: .utf8) ?? "NO DATA")
                        completion(.success(data))
                        
                    default:
                        
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.failure(NetworkError.serverError))
                        }
                        
                        
                }
            }
            
            task.resume()
            
        }
        catch let err {
            print("JSON DECODE ERROR: \(err)")
        }
    }
}
//class LASApi {
//
//    static let shared = LASApi()
//
//    var gatewayName: String = "gatewaydemo"
//
//    var ENVIRONMENT: Environment!
//    let session = URLSession.shared
//
//    func getBaseUrl() -> String {
//        switch ENVIRONMENT {
//            case .staging:
//                return "https://unity-dev.las.smallcase.com/"
//            case .development:
//                return "https://unity-dev.las.smallcase.com/"
//            default:
//                return "https://unity-dev.las.smallcase.com/"
//        }
//    }
//
//    func createInteractionToken(_ createInteractionBody: CreateInteractionBody, completion: @escaping ((Result<Data, Error>) -> Void)) {
//
//        let urlString = "\(getBaseUrl())/backend/\(self.gatewayName)v1/interaction"
//
//        let bodyParams: [String: Any] = createInteractionBody.dictionary!
//
//        guard let urlRequest = getUrlRequest(from: urlString, with: bodyParams) else {
//            completion(.failure(NetworkError.invalidUrl))
//            return
//        }
//    }
//
//    private func getUrlRequest(from urlString: String,with params: [String: Any]) -> URLRequest? {
//        guard let url = URL(string: urlString) else {
//            return nil
//        }
//
//        var urlRequest = URLRequest(url: url)
//        urlRequest.cachePolicy = .reloadRevalidatingCacheData
//        urlRequest.httpMethod = HTTPRequest.post
//        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
//            return nil
//        }
//
//        urlRequest.httpBody = httpBody
//
//        return urlRequest
//    }
//
//    private func makeApiCall(with urlRequest: URLRequest, completion: @escaping ((Result<Data, Error>) -> Void)) {
//        let task = session.dataTask(with: urlRequest) { (data, response, error) in
//
//            guard error == nil else {
//                completion(.failure(NetworkError.custom(message: error!.localizedDescription)))
//                return
//            }
//
//            guard let httpResponse = response as? HTTPURLResponse else { completion(.failure(NetworkError.noData))
//                return
//            }
//
//            print("------> Http response code: \(httpResponse.statusCode)")
//
//            switch httpResponse.statusCode {
//                case 200...299:
//
//                    guard let data = data else { return completion(.failure(NetworkError.noData)) }
//                    print("API RESPONSE ------------------>")
//                    // Convert to a string and print
//                    print(String(data: data, encoding: .utf8) ?? "NO DATA")
//                    completion(.success(data))
//
//                case 403:
//                    completion(.failure(NetworkError.accessDenied))
//
//                case 400:
//                    completion(.failure(NetworkError.accessDenied))
//
//                case 500...599:
//                    if data != nil {
//                        print("SERVER ERROR: \(String(describing: String(data: data!, encoding: .utf8)))")
//                    }
//                    completion(.failure(NetworkError.serverError))
//
//                default:
//
//                    if let error = error {
//                        completion(.failure(error))
//                    } else {
//                        completion(.failure(NetworkError.serverError))
//                    }
//
//
//            }
//
//        }
//
//        task.resume()
//    }
//}
