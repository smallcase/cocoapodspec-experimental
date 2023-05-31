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
    
    func createInteraction(completion: @escaping (Result<Data, Error>) -> Void) {
        let urlString = "\(getLASBaseUrl())/las/interaction"
        
        guard let url = URL(string: urlString) else { return }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.cachePolicy = .reloadRevalidatingCacheData
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let params = CreateInteractionBody(
            intent: LASSessionManager.lasIntent,
            config: CreateInteractionBody.CreateInteractionConfig(
                amount: LASSessionManager.losAmount,
                type: LASSessionManager.losType,
                lender: LASSessionManager.lender,
                userId: LASSessionManager.lasUser?.lasUserId,
                opaqueId: LASSessionManager.lasUser?.opaqueId
            )
        )
        
        do {
            let body =  try JSONEncoder().encode(params)
            print( "Create User Body: \(body)")
            
            urlRequest.httpBody = body
            
            print(String(data: body, encoding: .utf8) ?? "Create interaction body nil")
            
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
    
    func getUser(completion: @escaping (Result<Data, Error>) -> Void) {
        let urlString = "\(getLASBaseUrl())/las/user?id=\(LASSessionManager.userId)"
        guard let url = URL(string: urlString) else { return }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.cachePolicy = .reloadRevalidatingCacheData
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
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
        } catch let err {
            print("JSON DECODE ERROR: \(err)")
        }
    }
}
