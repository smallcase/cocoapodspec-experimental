//
//  UIColor+ext.swift
//  SCGateway
//
//  Created by Aaditya Singh on 09/04/25.
//  Copyright © 2025 smallcase. All rights reserved.
//

import UIKit

extension UIColor {
    
    class func crossButton() -> UIColor {
        return UIColor(hex: 0x535B62)
    }
    
    class func primaryBlue() -> UIColor {
        return UIColor(hex: 0x1F7AE0)
    }
    
    class func  primaryTextMediumColor() -> UIColor {
        return UIColor(hex: 0x535B62)
    }
    
    class func primaryTextDarkColor() -> UIColor {
        return UIColor(hex: 0x2F363F)
    }
    
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
    
    convenience init(hex: Int) {
        self.init(
            red: (hex >> 16) & 0xFF,
            green: (hex >> 8) & 0xFF,
            blue: hex & 0xFF
        )
    }
}
