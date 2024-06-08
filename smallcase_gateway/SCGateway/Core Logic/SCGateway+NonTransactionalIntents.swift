//
//  SCGateway+NonTransactionalIntents.swift
//  SCGateway
//
//  Created by Ankit Deshmukh on 27/05/22.
//  Copyright © 2022 smallcase. All rights reserved.
//

import Foundation

extension SCGateway {
    
    //MARK: Lead Gen
    public func triggerLeadGen(presentingController: UIViewController,params:Dictionary<String,String>?, utmParams: Dictionary<String, String>?, retargeting: Bool?){
        
        if SessionManager.gatewayName != nil && SessionManager.sdkToken != nil {
            
            SessionManager.leadGenUtmParams = utmParams
            SessionManager.isRetargeting = retargeting
            
            let leadGenController = LeadGenController(params: params, showLoader: true, leadGenUtmParams: SessionManager.leadGenUtmParams, isRetargeting: SessionManager.isRetargeting)
            leadGenController.view.backgroundColor = UIColor.init(white: 0, alpha: 0.8)
            leadGenController.modalPresentationStyle = .overFullScreen
            presentingController.present(leadGenController, animated: false, completion: nil)
            
        }
    }
    
    //MARK: smallplug
    @objc public func launchSmallPlug(presentingController: UIViewController, smallplugData: SmallplugData?, completion: @escaping ((Any?, Error?) -> Void)) {
        
        if SessionManager.gatewayName == nil && SessionManager.sdkToken == nil {
            completion(false, ObjcTransactionError(error: .uninitialized))
        } else {
            
            print("------------------- Launching SmallPlug ------------------------")
            
            if let smallPlugData = smallplugData {
                
                SessionManager.smallplugTargetEndpoint = smallPlugData.targetEndpoint
                SessionManager.smallplugUrlParams = smallPlugData.params
            }
            
            DispatchQueue.main.async { [weak self] in
                
                self?.smallplugCoordinator = SmallplugCoordinator(presentingViewController: presentingController, completion: completion)
                self?.smallplugCoordinator.start()
            }
        }
    }
    
    @objc public func launchSmallPlug(
        presentingController: UIViewController,
        smallplugData: SmallplugData?,
        smallplugUiConfig: SmallplugUiConfig?,
        completion: @escaping ((Any?, Error?) -> Void)) {
            
            if SessionManager.gatewayName == nil && SessionManager.sdkToken == nil {
                completion(false, ObjcTransactionError(error: .uninitialized))
            } else {
                
                print("------------------- Launching SmallPlug ------------------------")
                
                if let smallPlugData = smallplugData {
                    
                    SessionManager.smallplugTargetEndpoint = smallPlugData.targetEndpoint
                    SessionManager.smallplugUrlParams = smallPlugData.params
                }
                
                DispatchQueue.main.async { [weak self] in
                    
                    self?.smallplugCoordinator = SmallplugCoordinator(presentingViewController: presentingController, completion: completion)
                    self?.smallplugCoordinator.start(smallplugUiConfig)
                }
            }
        }
    
    //MARK: Logout
    @objc public func logoutUser(presentingController: UIViewController, completion: @escaping ((Bool, Error?) -> Void)) {
        if SessionManager.gatewayName == nil || SessionManager.sdkToken == nil  || SessionManager.broker == nil {  completion(false, ObjcTransactionError(error: .apiError)) }
        
        else {
            DispatchQueue.main.async { [weak self] in
                self?.brokerSelectCoordinator = BrokerSelectCoordinator(
                    presentingViewController: presentingController,
                    nonTransactionalIntentType: .logout,
                    completion: completion
                )
                
                self?.brokerSelectCoordinator.logout()
            }
        }
        
    }
    
    //MARK: Show Orders
    @objc public func showOrders(presentingController: UIViewController, completion: @escaping ( (Bool, Error?) -> Void) ) {
        
        if SessionManager.gatewayName == nil && SessionManager.sdkToken == nil {
            completion(false, ObjcTransactionError(error: .uninitialized))
        } else {
            
            print("---------------------- Show Orders ----------------------")
            
            SessionManager.showOrders = true
            
            DispatchQueue.main.async { [weak self] in
                self?.brokerSelectCoordinator = BrokerSelectCoordinator(
                    presentingViewController: presentingController,
                    nonTransactionalIntentType: .showOrders,
                    completion: completion
                )
                
                self?.brokerSelectCoordinator.showOrders()
            }
        }
    }
    
}
