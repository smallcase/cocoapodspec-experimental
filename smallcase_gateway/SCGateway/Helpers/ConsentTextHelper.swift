//
//  ConsentTextHelper.swift
//  SCGateway
//
//  Created by Dip on 12/08/20.
//  Copyright © 2020 smallcase. All rights reserved.
//

import Foundation
import SwiftUI

extension String{

    func sanitizeDistributor(brokerDisplayName:String) -> String {
      return  self.replacingOccurrences(of: "<DISTRIBUTOR>", with: brokerDisplayName)
    }
    
    func sanitizeBroker(brokerName: String) -> String {
        return  self.replacingOccurrences(of: "<BROKER>", with: brokerName)
    }
    
    func processText(del1:String,del2:String,textSize:CGFloat) -> NSAttributedString {
        let pattern = "\(del1)(.*?)\(del2)"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0,length:  self.count)
        let matches = (regex?.matches(in: self, options: [], range: range))!

        let attrString = NSMutableAttributedString(string: self, attributes:nil)
        print(matches.count)
        //Iterate over regex matches
        for match in matches {
            //Properly print match range
            print(match.range)

            //Get username and userid
            let userName = attrString.attributedSubstring(from: match.range(at: 0)).string
            
            print(userName)
            let bold = UIFont(name: "GraphikApp-Medium", size: textSize)!
            let multipleAttributes: [NSAttributedString.Key : Any] = [
                NSAttributedString.Key.foregroundColor: ScgatewayColor.TextColor.consentTextBold,
            NSAttributedString.Key.font: bold ]
            let myAttStr = NSAttributedString(string: userName, attributes: multipleAttributes)
            attrString.replaceCharacters(in: match.range(at: 0), with: myAttStr)

//            //A basic idea to add a link attribute on regex match range
//            attrString.addAttribute(NSAttributedString.Key.link, value: "\(userId)", range: match.range(at: 0))
//
//            //Still text it's in format @(steve|user_id) how could replace it by @steve keeping the link attribute ?
//            attrString.replaceCharacters(in: match.range(at: 1), with: "@\(userName)")
        }
        
        attrString.mutableString.replaceOccurrences(of: del1, with: "", options: .caseInsensitive, range: NSMakeRange(0, attrString.length))
        attrString.mutableString.replaceOccurrences(of: del2, with: "", options: .caseInsensitive, range: NSMakeRange(0, attrString.length))
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        attrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
        return attrString
    }
    
    func processText(del1:String,del2:String,textSize:CGFloat, mods: [String: [String:String]?]?) -> NSAttributedString {
        let pattern = "\(del1)(.*?)\(del2)"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0,length:  self.count)
        let matches = (regex?.matches(in: self, options: [], range: range))!

        let attrString = NSMutableAttributedString(string: self, attributes:nil)
        print(matches.count)
        //Iterate over regex matches
        for match in matches {
            //Properly print match range
            print(match.range)

            //Get username and userid
            let userName = attrString.attributedSubstring(from: match.range(at: 0)).string
            
            print(userName)
            let bold = UIFont(name: mods!["annotatedTextFont"]!!["annotatedFontFamily"]!, size: mods!["textSize"]!!["fontSize"]!.CGFloatValue)!
            let multipleAttributes: [NSAttributedString.Key : Any] = [
                NSAttributedString.Key.foregroundColor: UIColor(
                    hex: mods!["annotatedTextColor"]!!["annotatedFontColor"]!,
                    alpha: 1.0
                ) as Any,
            NSAttributedString.Key.font: bold ]
            let myAttStr = NSAttributedString(string: userName, attributes: multipleAttributes)
            attrString.replaceCharacters(in: match.range(at: 0), with: myAttStr)
        }
        
        attrString.mutableString.replaceOccurrences(of: del1, with: "", options: .caseInsensitive, range: NSMakeRange(0, attrString.length))
        attrString.mutableString.replaceOccurrences(of: del2, with: "", options: .caseInsensitive, range: NSMakeRange(0, attrString.length))
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.allowsDefaultTighteningForTruncation = true
        attrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
        return attrString
    }
}
