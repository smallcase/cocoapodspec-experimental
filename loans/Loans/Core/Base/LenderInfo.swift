//
//  LenderInfo.swift
//  Loans
//
//  Created by Ankit Deshmukh on 22/05/23.
//

import Foundation

internal class LenderInfo: NSObject {
    
    let lenderName: String
    let losUrl: String
    let openPlatform: Bool
    let intent: String
    let isAuthRequired: Bool
    
    init(_ lenderName: String,_ losUrl: String, _ openPlatform: Bool, _ intent: String, _ isAuthRequired: Bool) {
        self.lenderName = lenderName
        self.losUrl = losUrl
        self.openPlatform = openPlatform
        self.intent = intent
        self.isAuthRequired = isAuthRequired
    }
}
