//
//  Task.swift
//  Loans
//
//  Created by Ankit Deshmukh on 06/05/23.
//

import Foundation

typealias Parameters = [String: Any]

enum Task {
    case requestPlain
    case requestParameters(Parameters)
}
