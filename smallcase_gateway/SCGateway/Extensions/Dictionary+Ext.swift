//
//  Dictionary+Ext.swift
//  SCGateway
//
//  Created by Ankit Deshmukh on 22/02/22.
//  Copyright © 2022 smallcase. All rights reserved.
//

import Foundation

extension Dictionary {
    
    var toJsonString : String? {
        
        do {
            let jsonObject = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            
            return String(bytes: jsonObject, encoding: String.Encoding.utf8)
            
        } catch let dictionaryError as NSError {
            
            print("Unable to convert dictionary to json String :\(dictionaryError)")
            
            return nil
        }
    }
    
    mutating func combine(dict: [Key: Value]?) {
        guard let safeDict = dict else {
            return
        }
        for (k, v) in safeDict {
            updateValue(v, forKey: k)
        }
    }
    
}
