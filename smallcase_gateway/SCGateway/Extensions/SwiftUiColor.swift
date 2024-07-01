//
//  SwiftUiColor.swift
//  SCGateway
//
//  Created by Ankit Deshmukh on 17/02/21.
//  Copyright © 2021 smallcase. All rights reserved.
//

import Foundation

extension UIColor {
    public convenience init?(hex: String, alpha: CGFloat) {
        let r, g, b: CGFloat
        
        if !hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 0)
            let hexColor = String(hex[start...])
            
            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat((hexNumber & 0x0000ff)) / 255
                    
                    let opacity = alpha
                    
                    self.init(red: r, green: g, blue: b, alpha: opacity)
                    return
                }
            }
        }
        
        return nil
    }
}
