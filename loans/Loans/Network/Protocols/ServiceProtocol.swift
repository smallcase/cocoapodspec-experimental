//
//  ServiceProtocol.swift
//  Loans
//
//  Created by Ankit Deshmukh on 06/05/23.
//

import Foundation

typealias Headers = [String: String]

protocol ServiceProtocol {
    var baseURL: URL { get }
    var path: String? { get }
    var method: HTTPMethod { get }
    var task: Task { get }
    var headers: Headers? { get }
    var parameterEncoding: ParametersEncoding { get }
}
