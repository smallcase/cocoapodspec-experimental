//
//  String+Ext.swift
//  SCGateway
//
//  Created by Shivani on 20/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation

extension String {
    
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
    
    var bool: Bool {
        switch self.lowercased() {
            case "true", "t", "yes", "y":
                return true
            case "false", "f", "no", "n", "":
                return false
            default:
                return false
        }
    }
    
    var CGFloatValue: CGFloat {
        guard let n = NumberFormatter().number(from: self ) else { return 0.0}
        
        return CGFloat(truncating: n)
    }
    
    var toDictionary : [String : Any]? {
        
        let data = Data(self.utf8)
        
        do {
            
            if let jsonDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                
                return jsonDictionary
            }
            
        } catch let error as NSError {
            print("Failed to convert JSON string to dictionary: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    func ignoreLeprechaun() -> String {
        guard self.hasSuffix("-leprechaun") else { return self }
        return String(self.dropLast("-leprechaun".count))
    }
    
    func extractQueryParam(_ fromUrl: String, queryParam: String) -> String? {
        guard let url = URLComponents(string: fromUrl) else { return nil }
        if let queryParamValue = url.queryItems?.first(where: { $0.name == queryParam })?.value {
            return queryParamValue
        }
        return nil
    }
    
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}
