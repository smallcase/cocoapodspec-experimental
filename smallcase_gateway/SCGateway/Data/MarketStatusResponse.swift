//
//  MarketStatusResponse.swift
//  SCGateway
//
//  Created by Shivani on 13/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation

struct MarketStatusResponse: Codable {
    var success: Bool
    var errors: [String]?
    var data: MarketStatus?
    
    struct MarketStatus: Codable {
        var broker: String?
        var marketOpen: Bool
        var amoActive: Bool
        var cancelAmoActive: Bool
        var activeDays: ActiveDays?
        
        struct ActiveDays: Codable {
            var isWorkingDay: Bool
            var nextActiveDay: String
            var previousActiveDay: String
            
            private enum CodingKeys: String, CodingKey {
                case isWorkingDay, nextActiveDay, previousActiveDay
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case broker, marketOpen, amoActive, cancelAmoActive
        }
    }
}

