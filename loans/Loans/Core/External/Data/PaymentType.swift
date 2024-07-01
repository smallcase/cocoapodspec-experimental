//
//  PaymentType.swift
//  Loans
//
//  Created by Ankit Deshmukh on 10/05/23.
//

import Foundation

@objc public enum PaymentType: NSInteger {
    
    case principal = 0
    case interest = 1
    case shortfall = 2
    case closure = 3
    
    var intValue: Int {
        return self.rawValue
    }
    
    init?(intValue: Int) {
        self.init(rawValue: intValue)
    }
    
    public var rawValue: NSInteger {
        switch self {
            case .principal:
                return 0
            case .interest:
                return 1
            case .shortfall:
                return 2
            case .closure:
                return 3
        }
    }
}
