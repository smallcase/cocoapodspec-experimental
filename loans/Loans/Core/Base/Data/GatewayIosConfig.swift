//
//  LoanConfig.swift
//  Loans
//
//  Created by Aaditya Singh on 27/02/24.
//

import Foundation

struct GatewayIosConfig: Codable {
    let id: Int?
    let createdAt, updatedAt: String?
    let mixpanel: MixpanelConfig?

    enum CodingKeys: String, CodingKey {
        case id, mixpanel
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct MixpanelConfig: Codable {
    let id: Int?
    let projectKey: String?
    let gateways: [String]?
}
