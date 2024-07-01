//
//  MFTransaction.swift
//  SCGateway
//
//  Created by Indrajit Roy on 22/09/22.
//  Copyright © 2022 smallcase. All rights reserved.
//

import Foundation

protocol TransactionStatusI {
    var isSuccess : Bool { get }
    var isError : Bool { get }
}

struct MFTransaction : Codable, TransactionStatusI {
    var isSuccess: Bool {
        get {
            return status == TransactionOrderStatus.completed.rawValue || status == TransactionOrderStatus.processing.rawValue
        }
    }
    
    var isError: Bool {
        get {
            error?.value == true
        }
    }
    
    
    var orderConfig: MFOrderConfig?
    var error: TransactionErrorResponse?
    var postbackStatus: PostbackStatus?
    var intendedActionInitiated: Bool?
    var intent: String?
    var expireAt: String?
    var status: String?
    var gateway: String?
    var transactionId: String?
    var createdAt: String?
    var updatedAt: String?
    var _v: Int?
    var expired: Bool?
    var success: Transaction.SuccessData?
    
    enum CodingKeys: String, CodingKey {
        case orderConfig, error, postbackStatus, intendedActionInitiated, intent, expireAt, status, gateway, transactionId, createdAt, updatedAt, _v, expired, success
    }
}

struct MFOrderConfig : Codable {
    var orderIds: [String]?
    var batchIds: [String]?
    var reconIds: [String]?
    var orders: [String]?
    
    enum CodingKeys: String, CodingKey {
        case orderIds, batchIds, reconIds, orders
    }
}

struct PostbackStatus : Codable {
    var order: String?
    var holding: Int?
    var retryAfter: String?
    var lastTry: String?
    
    enum CodingKeys: String, CodingKey {
        case order, holding, retryAfter, lastTry
    }
}
