//
//  ProviderProtocol.swift
//  Loans
//
//  Created by Ankit Deshmukh on 06/05/23.
//

import Foundation

protocol ProviderProtocol {
    func request<T>(type: T.Type, service: ServiceProtocol, completion: @escaping(Result<T, NetworkError>) -> ()) where T: Decodable
}
