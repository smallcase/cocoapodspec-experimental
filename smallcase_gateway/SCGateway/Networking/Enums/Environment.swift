//
//  Environment.swift
//  SCGateway
//
//  Created by Shivani on 06/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

//TODO:- Make internal before release
@objc public enum Environment: Int {
    case development
    case production
    case staging
    
    var mfTxnBaseUrl: String {
        switch self {
        case .development:
            "https://mf-dev.smallcase.com/"
        case .staging:
            "https://mf-stag.smallcase.com/"
        default:
            "https://mf.smallcase.com/"
        }
    }
}


