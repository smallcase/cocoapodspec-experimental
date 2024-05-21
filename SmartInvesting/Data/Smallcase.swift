//
//  Smallcase.swift
//  WebViewTester
//
//  Created by Shivani on 18/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation

struct SmallcaseStatistics: Codable {
    var minInvestAmount: Double?
    var minSipAmount: Double?
    var indexValue: Double?
    
    enum CodingKeys: String, CodingKey {
        case minInvestAmount, minSipAmount, indexValue
    }
}

struct Smallcase: Codable {
    
    var benchmark: Benchmark
    var info: SmallcaseInfo
    var constituents: [Constituent]?
    var scid: String
    var stats: SmallcaseStatistics?
    
    
    
    struct SmallcaseInfo: Codable {
        var name: String
        var type: String
        
        var shortDescription: String
        
        private enum CodingKeys: String, CodingKey {
            case name, type, shortDescription
        }
    }
    
    
    enum CodingKeys: String, CodingKey {
        case benchmark, info, constituents, scid, stats
    }
}
