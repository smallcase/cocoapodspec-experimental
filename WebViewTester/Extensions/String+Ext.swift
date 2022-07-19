//
//  String+Ext.swift
//  WebViewTester
//
//  Created by Ankit Deshmukh on 08/07/22.
//  Copyright © 2022 smallcase. All rights reserved.
//

import Foundation

extension String {
    
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
}
