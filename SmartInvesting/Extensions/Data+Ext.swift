//
//  Data+Ext.swift
//  WebViewTester
//
//  Created by Ankit Deshmukh on 30/05/23.
//  Copyright © 2023 smallcase. All rights reserved.
//

import Foundation

internal extension Data {
    
    func toJson() -> [String: Any]? {
        do {
            // make sure this JSON is in the format we expect
            if let jsonDict = try JSONSerialization.jsonObject(with: self, options: []) as? [String: Any] {
                return jsonDict
            }
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
        }
        
        return nil
    }
}
