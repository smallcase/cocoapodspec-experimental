//
//  Transaction.swift
//  SCGateway
//
//  Created by Shivani on 18/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation

public struct Transaction: Codable {
    
    var orderConfig: OrderConfig?
    var config: MetaOrderConfig?
    var subscriptionConfig: SubscriptionConfig?
    var expireAt: String?
    var intent: String?
    var platform: Platform?
    var status: String?
    var gateway: String?
    var transactionId: String?
    var createdAt: String?
    var updatedAt: String?
    var successData: Data?
    var error: TransactionErrorResponse?
    var authId: String?
    var expired: Bool?
    var flags: TransactionFlags?
    
    var successDict: [String:Any]? {
        guard let dataDictFromBackend = successData?.toJson() else {
            return nil
        }
        var partnerDataDict = dataDictFromBackend
        if let nestedDataDict = dataDictFromBackend["data"] as? [String:Any] {
            partnerDataDict["data"] = nil
            partnerDataDict.combine(dict: nestedDataDict)
        }
        return partnerDataDict
    }
    
    var successString: String? {
        return successDict?.toJsonString
    }
    
    var success: SuccessData {
        get {
            let defaultValue = SuccessData()
            guard let data = successData else {
                return defaultValue
            }
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode(SuccessData.self, from: data) {
                return decoded
            }
            return defaultValue
        }
    }
    
    
    internal struct Platform: Codable {
        var url: String?
        var openMode: String?
        var origins: [String]?
        
        private enum CodingKeys: String, CodingKey {
            case url, openMode, origins
        }
    }
    
    internal struct TransactionFlags: Codable {
        var isOrderRequested: Bool?
        
        private enum CodingKeys: String, CodingKey {
            case isOrderRequested
        }
    }
    
    public struct SuccessData: Codable {
        var data: OrderData?
        var smallcaseAuthToken: String?
        var broker: String?
        var signup:Bool?
        var transactionId: String?
        var notes: String?
        
        private enum CodingKeys: String, CodingKey {
            case data, smallcaseAuthToken, broker, signup, transactionId, notes
        }
        
    }
    
    enum CodingKeys: String, CodingKey {
        case orderConfig, config, expireAt, intent, platform, status, gateway, transactionId, createdAt, updatedAt, successData = "success", error, authId, expired, flags, subscriptionConfig
    }
    
    func getPlatformUrl() -> URL {
        if (orderConfig?.assetUniverse == ScAssetUniverse.MUTUAL_FUND.rawValue) {
            if let safePlatformUrl = platform?.url {
                return URL(string: safePlatformUrl) ?? URL(string: "https://")!
            }
            let baseEnvironment = SessionManager.baseEnvironment
            let baseUrl = baseEnvironment.mfTxnBaseUrl
            
            var urlComponents = URLComponents(string: baseUrl)
            urlComponents?.path.append("transaction/")
            urlComponents?.path.append(transactionId ?? "")
            let query = [
                URLQueryItem(name: "gateway", value: SessionManager.gatewayName),
                URLQueryItem(name: "clientType", value: Constants.clientDeviceType),
            ]
            
            urlComponents?.queryItems = query
            return urlComponents?.url ?? URL(string: "https://")!
        }
        return URL(string: "https://")!
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.orderConfig = try container.decodeIfPresent(OrderConfig.self, forKey: .orderConfig)
        self.config = try container.decodeIfPresent(MetaOrderConfig.self, forKey: .config)
        self.expireAt = try container.decodeIfPresent(String.self, forKey: .expireAt)
        self.intent = try container.decodeIfPresent(String.self, forKey: .intent)
        self.status = try container.decodeIfPresent(String.self, forKey: .status)
        self.gateway = try container.decodeIfPresent(String.self, forKey: .gateway)
        self.transactionId = try container.decodeIfPresent(String.self, forKey: .transactionId)
        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        do {
            let dictDecodable = try container.decode(Dictionary<String, AnyDecodable>.self, forKey: .successData)
            let dictAny = dictDecodable.mapValues { $0.value }
            let data = try JSONSerialization.data(withJSONObject: dictAny, options: [])
            self.successData = data
        } catch {
            self.successData = nil
        }
        self.error = try container.decodeIfPresent(TransactionErrorResponse.self, forKey: .error)
        self.authId = try container.decodeIfPresent(String.self, forKey: .authId)
        self.expired = try container.decodeIfPresent(Bool.self, forKey: .expired)
        self.platform = try container.decodeIfPresent(Platform.self, forKey: .platform)
        self.subscriptionConfig = try container.decodeIfPresent(SubscriptionConfig.self, forKey: .subscriptionConfig)
        self.flags = try container.decodeIfPresent(TransactionFlags.self, forKey: .flags)

    }
    
}

// Required only for intent = SUBSCRIPTION
public struct SubscriptionConfig: Codable {
    var scid: String?
    var name: String?
    
    enum CodingKeys: String, CodingKey {
        case scid, name
    }
}

public struct OrderConfig: Codable{
    var type: String?
    var assetUniverse: String?
    var scid: String?
    var name: String?
    var orders: [SstOrder]?
    
    enum CodingKeys: String, CodingKey {
        case type, assetUniverse, scid, name, orders
    }
}

public struct MetaOrderConfig: Codable {
    var orderName: String?
    var orderLogo: String?
    
    enum CodingKeys: String, CodingKey {
        case orderName, orderLogo
    }
}

public struct SstOrder: Codable {
    var quantity: Int?
    var type: String?
    var sid: String?
    
    var orderType: String?
    var validity: String?
    
    var sidInfo: SidInfo?
    
    enum CodingKeys: String, CodingKey {
        case quantity, type, sid, orderType, validity, sidInfo
    }
}


public struct SidInfo: Codable {
    //    var sector: String?
    //    var name: String?
    var ticker: String?
    //    var exchange: String?
    //    var description: String?
    //    var nseSeries: String?
    //    var tradable: Bool?
    //    var type: String?
    
    //    enum CodingKeys: String, CodingKey {
    //        case sector, name, ticker, exchange, description, nseSeries, tradable, type
    //    }
    
    enum CodingKeys: String, CodingKey {
        case ticker
    }
}

public struct Order: Codable {
    var orderType: String?
    var product: String?
    var exchange: String?
    var status: String?
    var quantity: Int?
    var tradingsymbol: String?
    var transactionType: String?
    var filledQuantity: Int?
    var averagePrice: Double?
    var exchangeOrderId:String?
    
    enum CodingKeys: String, CodingKey {
        case orderType, product, exchange, status, quantity, tradingsymbol, transactionType, filledQuantity, averagePrice,exchangeOrderId
    }
}



public struct OrderBatch: Codable {
    var filled: Int?
    var variety: String?
    var buyAmount: Double?
    var sellAmount: Double?
    var orders: [Order]?
    var unplaced: [Order]?
    var batchId: String?
    var quantity: Int?
    var status: String
    var completedDate: String?
    var transactionId:String?
    var label: String?
    var originalLabel: String?
    var dummy: Bool?
    
    
    enum CodingKeys: String, CodingKey {
        case filled, variety, buyAmount, sellAmount, orders, unplaced, batchId, quantity, status, completedDate, transactionId, label,originalLabel, dummy
    }
}
public struct OrderData: Codable {
    var batches: [OrderBatch]?
    var funds:Double?
    var sipDetails: SipDetail?
    //    var sipAction: String?
    var name:String?
    var scid:String?
    var iscid:String?
    var imageUrl:String?
    var smallcases: [SmallcaseDetails]?
    var source: String?
    
    enum CodingKeys: String, CodingKey {
        case batches, funds, sipDetails, name, scid, iscid, imageUrl, smallcases, source
    }
    
}

public struct SipDetail: Codable {
    
    var sipActive: Bool?
    var sipAction: String?
    var amount: Double?
    var frequency: String?
    var iscid: String?
    var scheduledDate: String?
    var scid: String?
    var sipType: String?
    
    enum CodingKeys: String, CodingKey {
        case sipActive, sipAction, amount, frequency, iscid, scheduledDate, scid, sipType
    }
}

