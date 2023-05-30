//
//  LASUser.swift
//  WebViewTester
//
//  Created by Ankit Deshmukh on 29/05/23.
//  Copyright © 2023 smallcase. All rights reserved.
//

import Foundation

//@available(iOS 13.0, *)
//class LASUser: ObservableObject {
//    @Published var pan: String? = nil
//    @Published var dob: String? = nil
//    @Published var userId: String? = nil
//    @Published var lender: String? = nil
//}

struct CreateUser: Codable {
    var pan: String
    var dob: String
    var id: String
    var lender: String
    
    enum CodingKeys: String, CodingKey {
        case pan, dob, id, lender
    }
}
