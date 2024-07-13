//
//  CMSRepository.swift
//  Loans
//
//  Created by Ankit Deshmukh on 22/06/23.
//

import Foundation

internal class CMSRepository: CMSRepositoryProtocol {
    
    
    private let cmsAPI: CMSAPI = CMSAPI()
    
    var lenderConfig: [LenderConfigs]? = nil
    
    func loadLenderConfig(completion: @escaping ((ScLoanResult<ScLoanSuccess>) -> Void)) {
        DispatchQueue.global(qos: .default).async {
            self.cmsAPI.getLenderConfig { result in
                
                switch result {
                    
                case .success(let lenderConfigs):
                    SessionManager.lenderConfig = lenderConfigs
                    self.lenderConfig = lenderConfigs
                    let dictionary: [String: Any] = [
                        "version": SessionManager.sdkVersion,
                        "versionCode": SessionManager.sdkVersionCode
                    ]
                    let data = dictionary.toJsonString
                    completion(.success(ScLoanSuccess(
                        data: data))
                    )
                    
                case .failure(_):
                    completion(.success(ScLoanSuccess()))
                }
            }
        }
    }
    
    func loadLenderConfig(completion: @escaping(ScLoanSuccess?, ScLoanError?) -> Void) {
        loadLenderConfig() { result in
            switch(result) {
            case .success(let response):
                completion(response, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
        
    }
}
