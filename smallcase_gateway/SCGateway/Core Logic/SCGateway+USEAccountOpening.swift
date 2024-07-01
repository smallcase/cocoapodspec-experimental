//
//  SCGateway+USEAccountOpening.swift
//  SCGateway
//
//  Created by Ankit Deshmukh on 06/10/22.
//  Copyright © 2022 smallcase. All rights reserved.
//

import Foundation

extension SCGateway {
    
    public func openUsEquitiesAccount(presentingController: UIViewController) {
        
        if(self.isSDKInitialised()) {
            self.useAccOpeningCoordinator = USEAccOpeningCoordinator(presentingController)
            self.useAccOpeningCoordinator.start()
        }
    }
    
    public func openUsEquitiesAccount(
        presentingController: UIViewController,
        signUpConfig: SignUpConfig,
        completion: @escaping ((String?, Error?) -> Void)) {
            
            if(self.isSDKInitialised()) {
                self.useAccOpeningCoordinator = USEAccOpeningCoordinator(presentingController, signUpConfig, completion)
                self.useAccOpeningCoordinator.start()
            }
        }
    
    public func openUsEquitiesAccount(
        presentingController: UIViewController,
        signUpConfig: SignUpConfig? = nil) {
            
            if(self.isSDKInitialised()) {
                self.useAccOpeningCoordinator = USEAccOpeningCoordinator(presentingController, signUpConfig)
                self.useAccOpeningCoordinator.start()
            }
        }
    
    public func openUsEquitiesAccount(
        presentingController: UIViewController,
        signUpConfig: SignUpConfig,
        additionalConfig: [String: Any]? = nil,
        completion: @escaping ((String?, Error?) -> Void)) {
            
            if(self.isSDKInitialised()) {
                self.useAccOpeningCoordinator = USEAccOpeningCoordinator(presentingController, signUpConfig, additionalConfig, completion)
                self.useAccOpeningCoordinator.start()
            }
        }
    
    public func openUsEquitiesAccount(
        presentingController: UIViewController,
        signUpConfig: SignUpConfig,
        additionalConfig: [String: Any]? = nil) {
            
            if(self.isSDKInitialised()) {
                self.useAccOpeningCoordinator = USEAccOpeningCoordinator(presentingController, signUpConfig, additionalConfig)
                self.useAccOpeningCoordinator.start()
            }
        }
    
    //MARK: Network Calls
    
    internal func fetchLeadStatus(leadId: String? = nil, opaqueId: String? = nil) {
        
        if leadId == nil && opaqueId == nil {
            self.useAccOpeningCoordinator.submitLeadResponseAndFinish()
            return
        }
        
        sessionProvider.requestJson(service: GatewayService.getUSELeadStatus(leadId: leadId, opaqueId: opaqueId)) { [weak self] (result) in
            
            switch result {
                    
                case .success(let responseData):
                    print(responseData)
                    self?.useAccOpeningCoordinator.submitLeadResponseAndFinish(leadStatusResponse: responseData)
                    
                case .failure(let networkError):
                    print(networkError)
                    self?.useAccOpeningCoordinator.submitLeadResponseAndFinish(error: networkError)
            }
        }
    }
}
