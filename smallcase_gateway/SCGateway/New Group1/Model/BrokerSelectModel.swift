//
//  BrokerSelectModel.swift
//  SCGateway
//
//  Created by Shivani on 06/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

protocol BrokerSelectModelProtocol {
    func getBrokerData(completion: @escaping(Result<[BrokerConfig], NetworkError>) -> Void)
    func getAllowedBrokers() -> [String]?
}


struct BrokerSelectModel: BrokerSelectModelProtocol {
    
    func getBrokerData(completion: @escaping(Result<[BrokerConfig], NetworkError>) -> Void) {
            
            let allowedBrokers = self.getAllowedBrokers()
       
            var filteredBrokerList : [BrokerConfig] = []
                
            var allowedBrokersForIntent: [String] = []
        
            SessionManager.moreBrokers.removeAll()
            
            if (SessionManager.rawBrokerConfig.count != 0) {
                
                completion(Result.success({ () -> [BrokerConfig] in
                    
                    ///First priority is of the connected broker of the user if any
                    if let userData = SessionManager.userData, SessionManager.userStatus == .connected {
                        
                        /// user is already connected, login for only connected broker
                        
                        let connectedBroker = userData.broker?.name
                        
                        if SessionManager.showOrders && !allowedBrokers!.contains(connectedBroker!.ignoreLeprechaun()) {
                            return []
                        }
                        
                        filteredBrokerList = SessionManager.rawBrokerConfig.filter({ (configItem) -> Bool in
                            return connectedBroker?.contains(configItem.broker) ?? false
                        })
                    }
                    
                    /**
                     * Second priority is given to the customBrokerConfig list (if set) from the SetUp method
                     * This allows to narrow the list of brokers dependency on support of the gateway owners
                     */
                    else if (SessionManager.brokerConfigType != nil) {
                        
                        switch SessionManager.brokerConfigType {
                            
                            case .custom(let customBrokerConfigArray):
                                
                                let intersectedList = customBrokerConfigArray.filter({ (brokerConfig) -> Bool in
                                    return allowedBrokers?.contains(brokerConfig) ?? false
                                })
                                
                                for brokerItem in SessionManager.rawBrokerConfig {
                                    if intersectedList.contains(brokerItem.broker) {
                                        filteredBrokerList.append(brokerItem)
                                    }
                                }
                                
                            case .defaultConfig: break
                                
                            case .none: break
                        }
                        
                    }
                    
                    /// If the user is not a CONNECTED user and custom broker list was not passed during Setup method call.
                    
                    if filteredBrokerList.isEmpty && SessionManager.brokerConfigType == BrokerConfigType.defaultConfig {
                        filteredBrokerList = SessionManager.rawBrokerConfig.filter({ (configItem) -> Bool in
                            return allowedBrokers?.contains(configItem.broker) ?? false
                        })
                    }
                    
                    SessionManager.allBrokers = filteredBrokerList
                    
                    for brokerConfig in filteredBrokerList {
                        allowedBrokersForIntent.append(brokerConfig.broker)
                    }
                    
                    SessionManager.allowedBrokersForIntent = allowedBrokersForIntent
                    
                    let topBrokers = filteredBrokerList.filter({ (configItem) -> Bool in
                        return configItem.topBroker
                    }).sorted { (c1, c2) -> Bool in
                        c1.brokerShortName?.caseInsensitiveCompare(c2.brokerShortName ?? "") == ComparisonResult.orderedAscending
                    }
                    
                    let normalBrokers = filteredBrokerList.filter({ (configItem) -> Bool in
                        return !configItem.topBroker
                    })
                    
                    filteredBrokerList = topBrokers
                    filteredBrokerList.append(contentsOf: normalBrokers)
                    
                    filteredBrokerList = filteredBrokerList.sorted(by: { (b1, b2) -> Bool in
                        b1.popularity < b2.popularity
                    })
                    
                    var recentBrokersList: [BrokerConfig] = []
                    
                    if let data = UserDefaults.standard.data(forKey: "recent_broker_list") {
                        do {
                            let decoder = JSONDecoder()
                            
                            // Decode Recent Broker Config List
                            recentBrokersList = try decoder.decode([BrokerConfig].self, from: data)
                            
                        } catch {
                            print("Unable to Decode Recent Broker List (\(error))")
                        }
                    }
                    
                    if(recentBrokersList.count > 1) {
                        recentBrokersList.reverse()
                    }
                    
                    for brokerConfig in recentBrokersList {
                        if(allowedBrokers != nil && !(allowedBrokers!.contains(brokerConfig.broker))) {
                            recentBrokersList.remove(at: recentBrokersList.firstIndex(of: brokerConfig)!)
                        }
                    }

                    if(filteredBrokerList.count > 9) {
                        
                        let firstFoldBrokers = filteredBrokerList[0...7].sorted { (b1, b2) -> Bool in
                            
                            b1.brokerShortName?.caseInsensitiveCompare(b2.brokerShortName ?? "") == ComparisonResult.orderedAscending
                            
                        }
                        
                        let secondFoldBrokers = filteredBrokerList[8...].sorted { (b1, b2) -> Bool in
                            
                            b1.brokerShortName?.caseInsensitiveCompare(b2.brokerShortName ?? "") == ComparisonResult.orderedAscending
                            
                        }
                        
                        filteredBrokerList = firstFoldBrokers
                        filteredBrokerList.append(contentsOf: secondFoldBrokers)
                        
                        SessionManager.allBrokers = filteredBrokerList
                        
                        for index in 9..<filteredBrokerList.count {
                                SessionManager.moreBrokers.append(filteredBrokerList[index])
                        }
//                        filteredBrokerList = filteredBrokerList.dropLast(filteredBrokerList.count - 9)
                    } else {
                        
                        filteredBrokerList = filteredBrokerList.sorted { (c1, c2) -> Bool in
                            c1.brokerShortName?.caseInsensitiveCompare(c2.brokerShortName ?? "") == ComparisonResult.orderedAscending
                        }
                        
                    }
                    
                    for broker in filteredBrokerList {
                        
                        if(!recentBrokersList.contains(where: { $0.brokerDisplayName == broker.brokerDisplayName})) {
                            recentBrokersList.append(broker)
                        }
                        
                    }
                    
                    recentBrokersList.removeDuplicates()
                    
                    filteredBrokerList = recentBrokersList

                    SessionManager.brokerConfig = filteredBrokerList
                    
                    if filteredBrokerList.count == 1 {
                        SessionManager.broker = Broker(name: filteredBrokerList.first?.broker)
                    }

                    return filteredBrokerList
                    }()))


                } else {
            SCGateway.shared.getBrokerConfig { (result) in
                      completion(result.map({ (config) -> [BrokerConfig] in
                        filteredBrokerList =  config.filter({(configItem) -> Bool in
                                return allowedBrokers?.contains(configItem.broker) ?? false
                            })
                            
                            switch SessionManager.brokerConfigType! {
                                       case .custom(let customConfigArray):
                                           
                                           filteredBrokerList = filteredBrokerList.filter({ (configItem) -> Bool in
                                               return  customConfigArray.contains(configItem.broker)
                                           })
                                          
                                           if filteredBrokerList.count == 1 {
                                               SessionManager.broker = Broker(name: filteredBrokerList.first?.broker)
                                           }
                            case .defaultConfig: break
                        }
                        if(filteredBrokerList.count > 9)
                            {
                                let topBrokers = filteredBrokerList.filter({(configItem) -> Bool in
                                    return configItem.topBroker
                                }).sorted { (c1, c2) -> Bool in
                                    c1.brokerShortName?.caseInsensitiveCompare(c2.brokerShortName ?? "") == ComparisonResult.orderedAscending
                                }
                                
                                let normalBrokers = filteredBrokerList.filter({ (configItem) -> Bool in
                                    return !configItem.topBroker
                                }).sorted { (c1, c2) -> Bool in
                                    c1.brokerShortName?.caseInsensitiveCompare(c2.brokerShortName ?? "") == ComparisonResult.orderedAscending
                                }
                                filteredBrokerList = topBrokers
                                filteredBrokerList.append(contentsOf: normalBrokers)
                                SessionManager.moreBrokers.removeAll()
                                for index in 9..<filteredBrokerList.count {
                                    SessionManager.moreBrokers.append(filteredBrokerList[index])
                                }
                                filteredBrokerList = filteredBrokerList.dropLast(filteredBrokerList.count - 9)
                        } else
                        {
                            filteredBrokerList = filteredBrokerList.sorted { (c1, c2) -> Bool in
                                c1.brokerShortName?.caseInsensitiveCompare(c2.brokerShortName ?? "") == ComparisonResult.orderedAscending
                            }
                        }
                            
                            return filteredBrokerList.sorted { (c1, c2) -> Bool in
                                c1.brokerShortName?.caseInsensitiveCompare(c2.brokerShortName ?? "") == ComparisonResult.orderedAscending
                            }
                       }))
                   
                   }
        }
       
    }
    
    func getAllowedBrokers() -> [String]? {
        
        if SessionManager.showOrders {
            
            return SessionManager.allowedBrokers[AllowedBrokerType.SHOW_ORDERS.rawValue]
            
        } else {
         
            switch SessionManager.currentIntent {
                case .connect:
                    return SessionManager.allowedBrokers[AllowedBrokerType.CONNECT.rawValue]
                case .authoriseHoldings:
                    return SessionManager.allowedBrokers[AllowedBrokerType.AUTHORISE_HOLDINGS.rawValue]
                case .fetchFunds:
                    return SessionManager.allowedBrokers[AllowedBrokerType.FETCH_FUNDS.rawValue]
                case .sipSetup:
                    return SessionManager.allowedBrokers[AllowedBrokerType.SIP_SETUP.rawValue]
                case .holdingsImport:
                    return SessionManager.allowedBrokers[AllowedBrokerType.HOLDINGS_IMPORT.rawValue]
                case .subscription:
                    return SessionManager.allowedBrokers[AllowedBrokerType.SMT.rawValue]
                default:
                    if SessionManager.type == "SECURITIES" {
                        return SessionManager.allowedBrokers[AllowedBrokerType.SST.rawValue]
                    } else {
                        return SessionManager.allowedBrokers[AllowedBrokerType.SMT.rawValue]
                    }
            }
            
        }
        
    }

}
