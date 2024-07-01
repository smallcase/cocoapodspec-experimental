//
//  Data+Exy.swift
//  Loans
//
//  Created by Ankit Deshmukh on 22/05/23.
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
