//
//  GetHoldingsResponse.swift
//  WebViewTester
//
//  Created by Dip on 29/04/20.
//  Copyright © 2020 smallcase. All rights reserved.
//

import Foundation

struct GetHoldingsResponse:Codable {
    var data:HoldingsDataWrapperDTO
    var statusCode:Int
    
    enum CodingKeys:String, CodingKey {
    case data,statusCode
    }
    
}

struct HoldingsDataWrapperDTO:Codable{
    var success:Bool
    var errors:String?
    var data:HoldingsData
    var snapshotDate:String?
    var updating:Bool?
    
    enum CodingKeys:String,CodingKey{
        case success,errors,data,snapshotDate,updating
    }
}

struct HoldingsData:Codable {
    var lastUpdate: String
    var securities: Securities
    var smallcases:Smallcases
    var snapshotDate:String
    var updating:Bool?
    enum CodingKeys: String,CodingKey {
        case lastUpdate,securities,smallcases,snapshotDate,updating
    }
}

struct Securities: Codable{
    var holdings:[Holding]
    enum CodingKeys: String, CodingKey {
        case holdings
    }
    
}
struct Holding:Codable{
    var averagePrice:Double?
    var name:String
    var shares:Int
    var ticker:String
    enum CodingKeys:String,CodingKey {
        case averagePrice,name,shares,ticker
    }
}
struct Smallcases :Codable{
    var `private`:Private
    var `public`:[SmallcaseHoldingDTO]
    
    enum CodingKeys:String,CodingKey {
        case `private`,`public`
    }
}

struct Private: Codable {
    var stats:Stats
   
    
    enum CodingKeys:String,CodingKey {
        case stats
    }
}
struct Stats:Codable {
       var totalReturns:Double?
       var currentValue:Double?
       enum CodingKeys:String,CodingKey{
          case totalReturns,currentValue
       }
   }

struct SmallcaseHoldingDTO:Codable {
    var stats:Stats?
    var imageUrl:String?
    var name:String?
    var shortDescription:String?
    var constituents: [ConstituentsItem?]?
    var scid:String?
    
    
    struct ConstituentsItem:Codable {
        var shares:Int?
        var ticker:String?
       private enum CodingKeys:String,CodingKey {
            case shares,ticker
        }
    }
    enum CodingKeys:String,CodingKey {
        case stats,imageUrl,name,shortDescription,constituents,scid
    }
    
}
