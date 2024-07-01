//
//  Data+ext.swift
//  SCGateway
//
//  Created by Ankit Deshmukh on 14/12/22.
//  Copyright © 2022 smallcase. All rights reserved.
//

import Foundation

extension Data {
    
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
