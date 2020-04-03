//
//  NetworkError.swift
//  SCGateway
//
//  Created by Shivani on 06/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//


public enum NetworkError: Error {
   case unknown
    case noJSONData
    case custom(message: String)
    case invalidStatusCode
    case nullData
    case serverError
    case invalidParams
    case accessDenied
}
