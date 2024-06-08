//
//  CMSAPI.swift
//  Loans
//
//  Created by Ankit Deshmukh on 30/05/23.
//

import Foundation

internal class CMSAPI: NSObject {
    
    private let cmsApiProvider = ApiProvider()
    
    func getLenderConfig(completion: @escaping(Result<[LenderConfigs], NetworkError>) -> Void) {
        
        cmsApiProvider.request(type: [LenderConfigs].self, service: CMSService.getLenderConfig) { result in
            completion(result)
        }
    }
    
    func getGatewayIosConfig(completion: @escaping(Result<Bool, Error>) -> Void) {
        cmsApiProvider.request(type: GatewayIosConfig.self, service: CMSService.getGatewayIosConfig) { (result) in
            switch result {
                case .success(let response):
                    SessionManager.gatewayIosConfig = response
                    completion(.success(true))
                case .failure(let error):
                    print(error)
                    completion(.failure(error))
            }
        }
    }
}
