//
//  NetworkError.swift
//  Loans
//
//  Created by Ankit Deshmukh on 06/05/23.
//

import Foundation

internal enum NetworkError: Error {
    case unknown
    case noJSONData
    case custom(message: String)
    case invalidStatusCode
    case nullData
    case serverError
    case invalidParams
    case accessDenied
}
