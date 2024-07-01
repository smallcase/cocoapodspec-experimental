//
//  LenderConfigs.swift
//  Loans
//
//  Created by Ankit Deshmukh on 31/05/23.
//

import Foundation

struct LenderConfigs: Codable, Hashable {
    var id: Int
    var lender: String?
    var displayName: String?
    var primaryColor: String?
    var imageURL: String?
    var showLoadingScreen: Bool?
    var created_at: String?
    var updated_at: String?
    var lamfInterestPercent: Double?
    var lamfDebtLtvPercent: Double?
    var lamfEquityLtvPercent: Double?
    var launchFE: String?
    var loaderTitleText: LoaderTextConfig?
    var loaderDescriptionText: LoaderTextConfig?
    
    struct LoaderTextConfig: Codable, Hashable {
        var id: Int?
        var loan_application: String?
        var payment: String?
        
        private enum CodingKeys: String, CodingKey {
            case id, loan_application, payment
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, lender, displayName, primaryColor, imageURL, showLoadingScreen, created_at, updated_at, lamfInterestPercent, lamfDebtLtvPercent, lamfEquityLtvPercent, launchFE, loaderTitleText, loaderDescriptionText
    }
}
