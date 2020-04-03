//
//  BrokerSelectModel.swift
//  SCGateway
//
//  Created by Shivani on 06/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

protocol BrokerSelectModelProtocol {
    func getBrokerData(completion: @escaping(Result<[BrokerConfig], NetworkError>) -> Void)
}


struct BrokerSelectModel: BrokerSelectModelProtocol {
    
    func getBrokerData(completion: @escaping(Result<[BrokerConfig], NetworkError>) -> Void){
        SCGateway.shared.getBrokerConfig { (result) in
           completion(result.map({ (config) -> [BrokerConfig] in
            let defaultConfig = config.filter({$0.gatewayVisible })
            
            switch Config.brokerConfigType! {
            case .defaultConfig:
                    return defaultConfig
            case .custom(let customConfigArray):
                
                let customConfig = defaultConfig.filter({ (configItem) -> Bool in
                    return  customConfigArray.contains(configItem.broker)
                })
                if customConfig.isEmpty{
                    return defaultConfig
                }
                if customConfig.count == 1 {
                    Config.broker = Broker(name: customConfig.first?.broker)
                }
                 return customConfig
            }
            
            }))
        
        }
    }

}
