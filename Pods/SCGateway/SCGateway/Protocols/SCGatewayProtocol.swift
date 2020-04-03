//
//  SCGatewayProtocol.swift
//  SCGateway
//
//  Created by Shivani on 13/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation


public protocol SCGatewayProtocol {
  //  func initializeGateway(sdkToken: String, gatewayName: String, completion: @escaping (Result<Bool, Error>) -> Void)
  //  func triggerTransactionFlow(transactionId: String, presentingController: UIViewController) throws
    
}

extension SCGatewayProtocol {
    func getBrokerConfig(completion: @escaping (Result<[BrokerConfig],NetworkError>) -> Void) {}
}
