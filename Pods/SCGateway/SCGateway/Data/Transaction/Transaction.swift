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
    var expireAt: String?
    var intent: String?
    var status: String?
    var gateway: String?
    var transactionId: String?
    var createdAt: String?
    var updatedAt: String?
    var success: SuccessData
    var error: TransactionErrorResponse?
    var authId: String?
    var expired: Bool?
    
    
    struct SuccessData: Codable {
        var data: OrderData?
        var smallcaseAuthToken: String?
        
        private enum CodingKeys: String, CodingKey {
            case data, smallcaseAuthToken
        }
        
    }
    
    
    struct OrderConfig: Codable{
        var type: String?
        var scid: String?
        var name: String?
        
        enum CodingKeys: String, CodingKey {
            case type, scid, name
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case orderConfig, expireAt, intent, status, gateway, transactionId, createdAt, updatedAt, success, error, authId, expired
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
    
    enum CodingKeys: String, CodingKey {
        case orderType, product, exchange, status, quantity, tradingsymbol, transactionType, filledQuantity, averagePrice
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
    var completedDate: String
    
    
    enum CodingKeys: String, CodingKey {
        case filled, variety, buyAmount, sellAmount, orders, unplaced, batchId, quantity, status, completedDate
    }
}
public struct OrderData: Codable {
    var batches: [OrderBatch]?
    
}
