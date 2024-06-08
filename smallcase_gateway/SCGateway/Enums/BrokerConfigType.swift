//
//  BrokerConfigType.swift
//  SCGateway
//
//  Created by Shivani on 21/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation

public enum BrokerConfigType {
    case defaultConfig
    case custom([String])
}

extension BrokerConfigType: Equatable {
    public static func ==(lhs: BrokerConfigType, rhs: BrokerConfigType) -> Bool {
        switch (lhs, rhs) {
            case (.defaultConfig, .defaultConfig):
                return true
            case (.custom(let lhsBrokersList), .custom(let rhsBrokersList)):
                return lhsBrokersList == rhsBrokersList
            default:
                return false
        }
    }
}
