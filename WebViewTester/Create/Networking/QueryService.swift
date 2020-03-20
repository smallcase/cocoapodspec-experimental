//
//  QueryService.swift
//  WebViewTester
//
//  Created by Shivani on 12/06/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation

let urlString = "https://api.tickertape.in/stocks/search"

class QueryService {
    
    typealias JSONDictionary = [String: Any]
    typealias QueryResult = ([Stock]?, String) -> ()
    
    let defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    var stocks: [Stock] = []
    var errorMessage = ""
    
    func getSearchResults(searchTerm: String, completion: @escaping QueryResult) {
        
        dataTask?.cancel()
        
        if var urlComponents = URLComponents(string: urlString) {
            urlComponents.query = "text=\(searchTerm)"
            
            guard let url = urlComponents.url else { return }
            
            dataTask = defaultSession.dataTask(with: url) { (data, response, error) in
                defer { self.dataTask = nil }
                
                if let error = error {
                self.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
                }
                else if let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200
                {
                    self.updateSearchResults(data)
                    DispatchQueue.main.async {
                        completion(self.stocks, self.errorMessage)
                    }
                }
                
            }
            
            dataTask?.resume()
            
        }
    }
    
    
    
    fileprivate func updateSearchResults(_ data: Data) {
        var response: JSONDictionary?
        stocks.removeAll()
        
        do {
           try response = JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
        } catch let parseError as NSError {
            errorMessage += "JSON Serialization error: \(parseError.localizedDescription)"
            return
        }
        
        guard let dataRes = response!["data"] as? JSONDictionary, let array = dataRes["searchResults"] as? [Any] else {
            errorMessage += "Dictionary does not contain results key\n"
            return
        }
        
        for stockJson in array {
            if let stockDictionary = stockJson as? JSONDictionary,
            let sid = stockDictionary["sid"] as? String,
            let stock = stockDictionary["stock"] as? JSONDictionary,
            let info = stock["info"] as? JSONDictionary,
            let ticker = info["ticker"] as? String,
            let name = info["name"] as? String {
                
                stocks.append(Stock(sid: sid, name: name, ticker: ticker))
                
            } else {
                errorMessage += "Problem parsing trackDictionary\n"
            }
            
        }
    }
    
    
}

