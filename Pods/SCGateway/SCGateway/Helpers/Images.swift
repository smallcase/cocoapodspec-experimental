//
//  Images.swift
//  SCGateway
//
//  Created by Shivani on 06/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

enum ImageConstants {
    static let fivePaisa = "fivepaisa"
    static let aliceBlue = "aliceblue"
    static let smallcaseIcon = "smallcaseIcon"
    static let closeIcon =  "closeIcon"
    static let successIcon = "successIcon"
    static let errorIcon = "errorIcon"
    static let smallcaseLoadingGif = ""
    static let orderInQueue = "loading-graphic"
    
}

var images: [String: UIImage?] = [
    "fivepaisa": UIImage(name: "broker-5paisa"),
    "aliceblue": UIImage(name: "broker-alice-blue"),
    "edelweiss": UIImage(name: "broker-edelweiss"),
    "hdfc": UIImage(name: "broker-hdfc"),
    "iifl": UIImage(name: "broker-iifl"),
    "kotak": UIImage(name: "broker-kotak"),
    "kite": UIImage(name: "broker-zerodha"),
    ImageConstants.smallcaseIcon: UIImage(name: "brand-smallcase"),
    ImageConstants.closeIcon: UIImage(name: "close"),
    ImageConstants.successIcon: UIImage(name: "success-large"),
    ImageConstants.errorIcon: UIImage(name: "error-large"),
    ImageConstants.orderInQueue: UIImage(name: "loading-graphic")
]


 extension UIImage {
    
    convenience init?(name: String) {
        let bundleId = "com.smallcase.SCGateway"
        self.init(named: name, in: Bundle(identifier: bundleId), compatibleWith: .none)
        
    }
}
