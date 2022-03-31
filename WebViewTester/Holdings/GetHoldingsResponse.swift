//
//  GetHoldingsResponse.swift
//  WebViewTester
//
//  Created by Dip on 29/04/20.
//  Copyright © 2020 smallcase. All rights reserved.
//

import Foundation

//MARK: Fetch Holdings Response
struct FetchHoldingsResponse: Codable {
    
    var statusCode: Int
    var data: FetchHoldingsData
    
    enum CodingKeys: String, CodingKey {
        case statusCode, data
    }
    
    //Fetch Holdings Response child 1
    struct FetchHoldingsData: Codable {
        
        var success: Bool
        var errors: String?
        var data: FetchHoldingsDataData
        
        private enum CodingKeys: String, CodingKey{
            case success, errors, data
        }
        
        //Fetch Holdings Response child 2
        struct FetchHoldingsDataData: Codable {
            
            var smallcases: FirstPartySmallcases
            var securities: [FetchHoldingsSecurities]
            var mutualFunds: FetchHoldingsMutualFunds?
            var updating: Bool?
            var lastUpdate: String
            var snapshotDate: String
            var smallcaseAuthId: String
            var broker: String
            
            private enum CodingKeys: String, CodingKey {
                case smallcases, securities, mutualFunds, updating, lastUpdate, snapshotDate, smallcaseAuthId, broker
            }
            
            struct FetchHoldingsMutualFunds: Codable {
                
                var holdings: [MutualFundsHoldings]?
                
                private enum CodingKeys: String, CodingKey {
                    case holdings
                }
            }
        }
    }
}

//MARK: Holdings - Securities
struct FetchHoldingsSecurities: Codable {
    
    var name: String?
    var isin: String?
    var bseTicker: String?
    var nseTicker: String?
    var smallcaseQuantity: Int?
    var transactableQuantity: Int?
    var holdings: SecuritiesHoldings?
    var positions: SecuritiesPositions?
    
    private enum CodingKeys: String, CodingKey {
        case name, isin, bseTicker, nseTicker, smallcaseQuantity, transactableQuantity, holdings
    }
    
    //Fetch Holdings Response child 3.1
    struct SecuritiesPositions: Codable {
        var nse: SecuritiesHoldings?
        var bse: SecuritiesHoldings?
        
        private enum CodingKeys: String, CodingKey {
            case nse, bse
        }
    }
    
    //Fetch Holdings Response child 3.2
    struct SecuritiesHoldings: Codable {
        
        var quantity: Int?
        var averagePrice: Double?
        
        private enum CodingKeys: String, CodingKey {
            case quantity, averagePrice
        }
    }
}

//MARK: Holdings - Mutual Funds
struct MutualFundsHoldings: Codable {
    
    var folio: String
    var fund: String
    var pnl: Double
    var quantity: Double
    var isin: String
    var averagePrice: Double
    var lastPriceDate: String
    var lastPrice: Double
    var xirr: Double
    
    private enum CodingKeys: String, CodingKey {
        case folio, fund, pnl, quantity, isin, averagePrice, lastPriceDate, lastPrice, xirr
    }
}

struct FirstPartySmallcases: Codable {
    
    var `private`: [SmallcaseHoldingDTO]
    var `public`: [SmallcaseHoldingDTO]
    
    enum CodingKeys: String, CodingKey {
        case `private`, `public`
    }
}

struct ThirdPartySmallcases: Codable {
    
    var privateSmallcases: Private
    var publicSmallcases: [SmallcaseHoldingDTO]
    
    enum CodingKeys: String, CodingKey {
        case privateSmallcases, publicSmallcases
    }
}

struct SmallcaseHoldingDTO: Codable {
    
    var scid: String?
    var name: String?
    var imageUrl: String?
    var shortDescription: String?
    var constituents: [ConstituentsItem?]?
    var stats: Stats?
    
    struct ConstituentsItem: Codable {
        var shares: Int?
        var ticker: String?
        
        private enum CodingKeys: String, CodingKey {
            case shares, ticker
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case stats, imageUrl, name, shortDescription, constituents, scid
    }
    
}

struct GetHoldingsResponse: Codable {
    var data:HoldingsDataWrapperDTO
    var statusCode:Int
    
    enum CodingKeys:String, CodingKey {
    case data,statusCode
    }
    
}

struct GetHoldingsResponseScObj: Codable {
    var data:HoldingsDataWrapperDTOscObj
    var statusCode:Int
    
    enum CodingKeys:String, CodingKey {
        case data,statusCode
    }
}

struct HoldingsDataWrapperDTOscObj:Codable{
    var success:Bool
    var errors:String?
    var data:HoldingsDataScObj
    var snapshotDate:String?
    var updating:Bool?
    
    enum CodingKeys:String,CodingKey{
        case success,errors,data,snapshotDate,updating
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

struct HoldingsDataScObj:Codable {
    var lastUpdate: String
    var securities: Securities
    var smallcases:SmallcasesPriObj
    var snapshotDate:String
    var updating:Bool?
    enum CodingKeys: String,CodingKey {
        case lastUpdate,securities,smallcases,snapshotDate,updating
    }
}

struct HoldingsData:Codable {
    var lastUpdate: String
    var securities: Securities
    var smallcases:FirstPartySmallcases
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
    var averagePrice:Double
    var name:String
    var shares:Int
    var ticker:String
    enum CodingKeys:String,CodingKey {
        case averagePrice,name,shares,ticker
    }
}

struct SmallcasesPriObj: Codable {
 
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

struct Stats: Codable {
       
    var totalReturns: Double?
    var currentValue: Double?
       
    enum CodingKeys: String, CodingKey{
          case totalReturns, currentValue
    }
}
