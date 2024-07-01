//
//  SmallcaseDetails.swift
//  SCGateway
//
//  Created by Shivani on 06/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation


struct SmallcaseDetails: Codable {
    var name: String?
    var source: String?
    var scid: String?
    var shortDescription: String?
    var date: String?
    var version: Int?
    var iscid: String?
    var batches: [OrderBatch]?
    
    
    private enum CodingKeys:String, CodingKey {
        case name
        case source
        case scid
        case shortDescription
        case date
        case version
        case iscid
        case batches
    }
}
