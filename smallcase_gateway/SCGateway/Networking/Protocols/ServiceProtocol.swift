//
//  ServiceProtocol.swift
//  SCGateway
//
//  Created by Shivani on 06/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//


typealias Headers = [String: String]

protocol ServiceProtocol {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var task: ScTask { get }
    var headers: Headers? { get }
    var parameterEncoding: ParametersEncoding { get }
}
