//
//  URLSessionProvider.swift
//  SCGateway
//
//  Created by Shivani on 06/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation

final class URLSessionProvider: ProviderProtocol {
    
    private var session: URLSessionProtocol
    
    init() {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 20.0
        sessionConfig.timeoutIntervalForResource = 60.0
        let session: URLSessionProtocol = URLSession.init(configuration: sessionConfig)
        self.session = session
    }
    
    func request<T>(type: T.Type, service: ServiceProtocol, completion: @escaping (Result<T, NetworkError>) -> ()) where T : Decodable {
        var request = URLRequest(service: service)
        request.cachePolicy = .reloadRevalidatingCacheData
        print(request)
        
        
        
        let task = session.dataTask(request: request, completionHandler: { [weak self] data, response, error in
            let httpResponse = response as? HTTPURLResponse
            self?.handleDataResponse(data: data, response: httpResponse, error: error, completion: completion)
        })
        
        task.resume()
    }
    
    
    
    private func handleDataResponse<T: Decodable>(data: Data?, response: HTTPURLResponse?, error: Error?, completion: (Result<T, NetworkError>) -> ()) {
        guard error == nil else {
            print(error.debugDescription)
            return completion(.failure(.custom(message: error?.localizedDescription ?? ""))) }
        guard let response = response else { return completion(.failure(.noJSONData)) }
        
        print(response.statusCode)
        switch response.statusCode { // 3
            
        case 500...599:
            if data != nil {
                print("SERVER ERROR: \(String(describing: String(data: data!, encoding: .utf8)))")
            }
            completion(.failure(.serverError))
            
        default:
            print(response)
            do {
                guard let data = data else { return completion(.failure(.nullData)) }
                let model = try JSONDecoder().decode(T.self, from: data)
                print(String(data: data, encoding: .utf8) ?? "")
                completion(.success(model))
            }
            catch let err {
                print("ERROR Thrown")
                print(err)
                completion(.failure(.noJSONData))
            }
            // 4
            
            
            
        }
    }
    
    func requestWithoutResParse(service: ServiceProtocol, completion: @escaping (Result<Data, Error>) -> Void) {
        var request = URLRequest(service: service)
        request.cachePolicy = .reloadRevalidatingCacheData
        print(request)
        
        
        
        let task = session.dataTask(request: request) { (data,response,error) in
            
            guard error == nil else {
                completion(.failure(NetworkError.custom(message: error!.localizedDescription)))
                return
            }
            
            guard (response as? HTTPURLResponse) != nil else { completion(.failure(NetworkError.noJSONData))
                return
            }
            
            guard let data = data else { return completion(.failure(NetworkError.nullData)) }
            print("API RESPONSE ------------------>")
            // Convert to a string and print
            print(String(data: data, encoding: .utf8) ?? "NO DATA")
            completion(.success(data))
            
            
        }
        
        task.resume()
    }
    
    func requestJson(service: ServiceProtocol, completion: @escaping (Result<Data, Error>) -> Void) {
        var request = URLRequest(service: service)
        request.cachePolicy = .reloadRevalidatingCacheData
        print(request)
        
        let task = session.dataTask(request: request) { (data, response, error) in
            
            guard error == nil else {
                completion(.failure(NetworkError.custom(message: error!.localizedDescription)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else { completion(.failure(NetworkError.noJSONData))
                return
            }
            
            print("------> Http response code: \(httpResponse.statusCode)")
            
            switch httpResponse.statusCode {
            case 200...299:
                
                guard let data = data else { return completion(.failure(NetworkError.nullData)) }
                print("API RESPONSE ------------------>")
                // Convert to a string and print
                print(String(data: data, encoding: .utf8) ?? "NO DATA")
                completion(.success(data))
                
            case 403:
                completion(.failure(NetworkError.accessDenied))
                    
            case 400:
                    completion(.failure(NetworkError.accessDenied))

            case 500...599:
                if data != nil {
                    print("SERVER ERROR: \(String(describing: String(data: data!, encoding: .utf8)))")
                }
                completion(.failure(NetworkError.serverError))
                
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
    
    
}
