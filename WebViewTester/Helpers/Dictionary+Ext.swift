//
//  Dictionary+Ext.swift
//  WebViewTester
//
//  Created by Ankit Deshmukh on 08/07/22.
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
    
}
