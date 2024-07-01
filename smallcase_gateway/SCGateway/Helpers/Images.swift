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
    static let closeIconWhite = "close_white"
    static let successIcon = "successIcon"
    static let errorIcon = "errorIcon"
    static let smallcaseLoadingGif = ""
    static let orderInQueue = "loading-graphic"
    static let expandLess = "expand-less"
    static let searchIcon = "search"
    static let twitter = "twitter"
    static let brokerCheck = "broker_check"
}

var images: [String: UIImage?] = [
    "fivepaisa": UIImage(named: "broker-5paisa", in: Bundle(for: SCGateway.self), compatibleWith: nil),//UIImage(name: "broker-5paisa"),
    "aliceblue": UIImage(named: "broker-alice-blue", in: Bundle(for: SCGateway.self), compatibleWith: nil),//UIImage(name: "broker-alice-blue"),
    "edelweiss": UIImage(named: "broker-edelweiss", in: Bundle(for: SCGateway.self), compatibleWith: nil),//UIImage(name: "broker-edelweiss"),
    "hdfc": UIImage(named: "broker-hdfc", in: Bundle(for: SCGateway.self), compatibleWith: nil),//UIImage(name: "broker-hdfc"),
    "iifl": UIImage(named: "broker-iifl", in: Bundle(for: SCGateway.self), compatibleWith: nil),//UIImage(name: "broker-iifl"),
    "kotak": UIImage(named: "broker-kotak", in: Bundle(for: SCGateway.self), compatibleWith: nil),//UIImage(name: "broker-kotak"),
    "kite": UIImage(named: "broker-zerodha", in: Bundle(for: SCGateway.self), compatibleWith: nil),//UIImage(name: "broker-zerodha"),
    ImageConstants.smallcaseIcon: UIImage(named: "brand-smallcase", in: Bundle(for: SCGateway.self), compatibleWith: nil),//UIImage(name: "brand-smallcase"),
    ImageConstants.closeIcon: UIImage(named: "close", in: Bundle(for: SCGateway.self), compatibleWith: nil),//UIImage(name: "close"),
    ImageConstants.closeIconWhite: UIImage(named: "closeWhite", in: Bundle(for: SCGateway.self), compatibleWith: nil),//UIImage(name: "closeWhite"),
    ImageConstants.successIcon: UIImage(named: "success-large", in: Bundle(for: SCGateway.self), compatibleWith: nil),//UIImage(name: "success-large"),
    ImageConstants.errorIcon: UIImage(named: "error-large", in: Bundle(for: SCGateway.self), compatibleWith: nil),//UIImage(name: "error-large"),
    ImageConstants.orderInQueue: UIImage(named: "loading-graphic", in: Bundle(for: SCGateway.self), compatibleWith: nil),//UIImage(name: "loading-graphic")
    ImageConstants.expandLess: UIImage(named: "expand-less", in: Bundle(for: SCGateway.self), compatibleWith: nil),
    ImageConstants.searchIcon: UIImage(named: "search", in: Bundle(for: SCGateway.self), compatibleWith: nil),
    ImageConstants.twitter: UIImage(named: "twitter", in: Bundle(for: SCGateway.self), compatibleWith: nil),
    ImageConstants.brokerCheck: UIImage(named: "broker_check", in: Bundle(for: SCGateway.self), compatibleWith: nil)
]


 extension UIImage {
    
    convenience init?(name: String) {
        //let bundleId = "com.smallcase.SCGateway"
        self.init(named: name, in: Bundle(for: SCGateway.self), compatibleWith: .none)
        
    }
}
