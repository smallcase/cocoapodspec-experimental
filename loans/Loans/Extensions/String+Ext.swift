//
//  String+Ext.swift
//  Loans
//
//  Created by Ankit Deshmukh on 30/05/23.
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
