//
//  TweetConfig.swift
//  SCGateway
//
//  Created by Dip on 08/06/20.
//  Copyright © 2020 smallcase. All rights reserved.
//

import Foundation

struct UpcomingBrokerConfig: Codable {
    
    var upcomingBrokers: [UpcomingBroker]
    
    
    
    
    private enum CodingKeys: String, CodingKey {
        
        case upcomingBrokers
    }

}

struct UpcomingBroker:Codable {
    var broker:String
    var brokerDisplayName:String
    var twitterHandle:String
    var upcoming: Bool
    var visible: Bool
    
    private enum CodingKeys: String, CodingKey {
          
          case broker,brokerDisplayName,twitterHandle,upcoming,visible
      }
}


