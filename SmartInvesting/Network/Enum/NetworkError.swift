//
//  NetworkError.swift
//  WebViewTester
//
//  Created by Ankit Deshmukh on 25/05/23.
//  Copyright © 2023 smallcase. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case accessDenied
    case serverError
    case invalidUrl
    case noData
    case parsingError
    case invalidParams
    case custom(message: String)
}
