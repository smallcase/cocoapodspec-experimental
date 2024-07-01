//
//  LASUserMode.swift
//  WebViewTester
//
//  Created by Ankit Deshmukh on 31/05/23.
//  Copyright © 2023 smallcase. All rights reserved.
//

import Foundation

@available(iOS 13.0, *)
class LASUserMode: ObservableObject {
    @Published var userMode: UserRegistrationMode = .newUser
}

enum UserRegistrationMode: Int {
    case newUser
    case existingUser
}
