//
//  UnityAPI.swift
//  Loans
//
//  Created by Ankit Deshmukh on 18/05/23.
//

import Foundation

internal class UnityAPI: NSObject {
    
    private let unityApiProvider = ApiProvider()
    
    func initialiseInteraction(_ interactionToken: String, completion: @escaping(Data?, Error?) -> Void) {
        unityApiProvider.requestJson(service: UnityService.interactionInit(interactionToken)) { (result) in
            switch result {
                case .success(let data):
                    print(data.debugDescription)
                    completion(data, nil)
                    
                case .failure(let error):
                    print(error.localizedDescription)
                    completion(nil, error)
            }
        }
    }
    
    func getInteractionStatus(_ interactionToken: String, _ feCode: Int? = nil, _ feMessage: String? = nil, completion: @escaping(Data?, Error?) -> Void) {
        unityApiProvider.requestJson(service: UnityService.interactionStatus(interactionToken, feCode, feMessage)) { (result) in
            switch result {
                case .success(let data): completion(data, nil)
                case .failure(let error): completion(nil, error)
            }
        }
    }
    
    func triggerLoanServicing(with endpoint: String, completion: @escaping(Data?, Error?) -> Void) {
        unityApiProvider.requestJson(service: UnityService.loanServicing(endpoint)) { (result) in
            switch result {
                case .success(let data): completion(data, nil)
                case .failure(let error): completion(nil, error)
            }
        }
    }
    
}
