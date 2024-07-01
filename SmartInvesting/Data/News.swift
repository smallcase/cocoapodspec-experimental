//
//  News.swift
//  WebViewTester
//
//  Created by Shivani on 19/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation

struct NewsResponse: Codable {
    var data: NewsData?
    var success: Bool
    var errors: [String]?
    
    
    struct NewsData: Codable {
        var news:  [News]?
        
        private enum CodingKeys: String, CodingKey {
            case news
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case data, success, errors
    }
}

struct News: Codable {
    
    var headline: String
    var imageUrl: String?
    var link: String
    var summary: String?
    
    enum CodingKeys: String, CodingKey {
        case headline, imageUrl, link, summary
    }
    
}
