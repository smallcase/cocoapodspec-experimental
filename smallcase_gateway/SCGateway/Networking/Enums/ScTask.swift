//
//  Task.swift
//  SCGateway
//
//  Created by Shivani on 06/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//


typealias Parameters = [String: Any]

enum ScTask {
    case requestPlain
    case requestParameters(Parameters)
}
