//
//  SCGateway.swift
//  SCGateway
//
//  Created by Shivani on 06/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import UIKit

//class SCGatew

@objc public protocol SCGatewayTransactionDelegate: class {
    
    @objc optional func shouldDisplayConnectCompletion() -> Bool
    
}

@objcMembers public class SCGateway: NSObject, SCGatewayProtocol {
    
    //MARK:- Variables
    
    ///Shared Instance
    public static let shared = SCGateway()
    
    public weak var delegate: SCGatewayTransactionDelegate?
    
    ///Network calls
    internal let sessionProvider = URLSessionProvider()
    
    private var brokerSelectCoordinator: BrokerSelectCoordinator!
    
    /// Closure to store any async action to be delayed while a current async call is going on
    private var pendingRequestClosure: (() -> Void)?
    
    /// To delay execution of other calls if init call is not completed
    private var isTransactionCallActive = false {
        
        didSet {
            if !isTransactionCallActive {
                guard pendingRequestClosure != nil else { return }
                pendingRequestClosure?()
                pendingRequestClosure = nil
            }
        }
    }
    
    private func registerAllFonts()
    {
        UIFont.jbs_registerFont(
            withFilenameString: "GraphikApp-Bold.ttf",
            bundle: Bundle(for: SCGateway.self)
        )
        UIFont.jbs_registerFont(
            withFilenameString: "GraphikApp-Light.ttf",
            bundle: Bundle(for: SCGateway.self)
            )
        UIFont.jbs_registerFont(
            withFilenameString: "GraphikApp-Medium.ttf",
            bundle: Bundle(for: SCGateway.self)
        )
        UIFont.jbs_registerFont(
            withFilenameString: "GraphikApp-MediumItalic.ttf",
            bundle: Bundle(for: SCGateway.self)
        )
        UIFont.jbs_registerFont(
            withFilenameString: "GraphikApp-Regular.ttf",
            bundle: Bundle(for: SCGateway.self)
        )
        UIFont.jbs_registerFont(
            withFilenameString: "GraphikApp-RegularItalic.ttf",
            bundle: Bundle(for: SCGateway.self)
        )
        UIFont.jbs_registerFont(
            withFilenameString: "GraphikApp-Semibold.ttf",
            bundle: Bundle(for: SCGateway.self)
        )
        for family: String in UIFont.familyNames
               {
                   print("\(family)")
                   for names: String in UIFont.fontNames(forFamilyName: family)
                   {
                          print("== \(names)")
                   }
               }
    }
    
    //MARK:- Methods
    
    @objc public func setup(config: GatewayConfig) {
       
       registerAllFonts()
        Config.gatewayName = config.gatewayName
        Config.brokerConfigType = config.brokerConfig
        Config.baseEnvironment = config.apiEnvironment
        Config.isLeprechaunActive = config.isLeprechaunActive
        getGatewayCopy { (result) in
            print(result)
        }
        
        getBrokerConfig { (result) in
            switch result {
            case .success(let brokerConfig):
                Config.brokerConfig = brokerConfig
                
            case .failure(let error):
                print(error)
            }
        }
    }
    /**
     - Parameter: gatewayName -> This is a unique name given to every gateway consumer
     - configType: select custom only if you want to support specific brokers
     */
    @objc public func initializeGateway(sdkToken: String, completion: ((Bool, Error?) -> Void)? ) {
        
        print("SCGATEWAY: -----------> [Initializer triggered]")
        
        guard let _ = Config.gatewayName, let _ = Config.brokerConfigType else {
            completion?(false, SCGatewayError.configNotSet)
            return
        }
        
        /// Creates a closure for any incoming async call if init is not completed
        if isTransactionCallActive {
            pendingRequestClosure = { [weak self] in
                self?.initializeGateway(sdkToken: sdkToken, completion: completion)
                
            }
            return
            
        }
        
        isTransactionCallActive = true
        
        Config.sdkToken = sdkToken
        
        sessionProvider.request(type: InitSessionResponse.self, service: GatewayService.initializeSession(smallcaseAuthToken: sdkToken)) { [weak self] (result) in
            switch result {
                
            case .success(let response):
                print(response)
                
                guard response.errors?.isEmpty ?? true else {
                    let errors = response.errors
                    // SDK initialised with invalid Gateway name
                    if errors?.contains(TransactionError.invalidGateway.errorValue!) ?? false {
                        completion?(false, TransactionError.invalidGateway)
                    }
                    else if errors?.contains(TransactionError.invalidJWT.errorValue!) ?? false {
                        completion?(false, TransactionError.invalidJWT)
                    }
                    else {
                         completion?(true, nil)
                    }
//                    else {
//                        completion?(false, TransactionError.internalError)
//                    }
                    return
                }
                
                Config.gatewayToken = response.data?.gatewayToken
                Config.csrfToken = response.data?.csrf
                Config.gateway = response.data
                Config.broker = response.data?.userData?.broker
                Config.userStatus = UserStatus(rawValue: response.data?.status ?? "GUEST")
                if let authToken = response.data?.smallcaseAuthToken  {
                    Config.sdkToken = authToken
                }
                
                completion?(true, nil)
                
                
            case .failure(let error):
                print(error)
                completion?(false, error)
                
            }
            print("INIT: call completed" )
            self?.isTransactionCallActive = false
        }
    }
    
    ///3.
    //
   
    public func triggerTransactionFlow(transactionId: String, presentingController: UIViewController, completion: @escaping(Result<TransactionIntent, TransactionError>) -> Void) throws {
    
        
        //Throws an error if config is not setup
        if Config.gatewayName == nil || Config.sdkToken == nil { throw SCGatewayError.uninitialized }
        //Gets the intent of the transaction
        fetchTransactionStatus(transactionId: transactionId) { [weak self] (result) in
            switch result {
            case .success(let response):
                
                guard let transaction = response.data?.transaction, let transactionIntent = self?.getTransactionType(transactionData: transaction) else {
                    //TODO: Failiure
                    return
                }
                
                switch transactionIntent {
                case .transaction:
                    print("TRANSACTION INTENT: \(transactionIntent)")
                    // Check if market is open
                                      
                    if Config.broker != nil {
                        
                        self?.checkMarketStatus(completion: { [weak self] (result) in
                            switch result {
                            case .success(let isOpen):
                                if !isOpen {
                                    completion(.failure(.marketClosed))
                                    return
                                }
                                /// Triggers BrokerSelect Coordinator
                                self?.openBrokerSelect(presentingController: presentingController, transactionId: transactionId, transactionIntent: true,completion: completion)
                                
                            case .failure(let error):
                                print(error)
                                completion(.failure(.internalError))
                            }
                        })
                    }
                    else {
                        self?.openBrokerSelect(presentingController: presentingController, transactionId: transactionId,transactionIntent: true ,completion: completion)
                                                       
                    }
                  
                    
                case .connect, .holdingsImport:
                    print("TRANSACTION INTENT: Connect/Holdings")
                    self?.openBrokerSelect(presentingController: presentingController, transactionId: transactionId,transactionIntent: false ,completion: completion)
                    
                }
                
            case .failure(let error):
                completion(.failure(error))
                print(error)
                
            }
            
        }
        
    }
    
    //Only for objective C compatibility
   @objc public func triggerTransactionFlow(transactionId: String, presentingController: UIViewController, completion: @escaping(Any?, ObjcTransactionError?) -> Void){
    
        //Throws an error if config is not setup
        if Config.gatewayName == nil || Config.sdkToken == nil {  completion(nil, ObjcTransactionError(error: .uninitialized)) }
        //Gets the intent of the transaction
        fetchTransactionStatus(transactionId: transactionId) { [weak self] (result) in
            switch result {
            case .success(let response):
                
                guard let transaction = response.data?.transaction, let transactionIntent = self?.getTransactionType(transactionData: transaction) else {
                    //TODO: Failiure
                    return
                }
                                      
                               
                switch transactionIntent {
                case .transaction:
                    print("TRANSACTION INTENT: \(transactionIntent)")
                    // Check if market is open
                    if Config.broker != nil {
                        
                        self?.checkMarketStatus(completion: { [weak self] (result) in
                                               switch result {
                                               case .success(let isOpen):
                                                   if !isOpen {
                                                    completion(nil, ObjcTransactionError(error: .marketClosed))
                                                   }
                                                   /// Triggers BrokerSelect Coordinator
                                                   
                                                   
                                                   self?.openBrokerSelect(presentingController: presentingController, transactionId: transactionId,transactionIntent: true ,completion: completion)
                                                   
                                               case .failure(let error):
                                                   print(error)
                                                   completion(nil, ObjcTransactionError(error: .internalError))
                                               }
                                           })
                        
                    }
                    else {
                        self?.openBrokerSelect(presentingController: presentingController, transactionId: transactionId,transactionIntent: true ,completion: completion)
                    }
                   
                    
                case .connect, .holdingsImport:
                    print("TRANSACTION INTENT: Connect/Holdings")
                    self?.openBrokerSelect(presentingController: presentingController, transactionId: transactionId,transactionIntent: false ,completion: completion)
                    
                }
                
            case .failure(let error):
                completion(nil, ObjcTransactionError(error: error))
                print(error)
                
            }
            
        }
        
    }
    
    //Only for objective C compatibility
    @objc private func openBrokerSelect( presentingController: UIViewController, transactionId: String,transactionIntent:Bool, completion: @escaping (Any?, ObjcTransactionError?) -> Void ) {
          DispatchQueue.main.async { [weak self] in
            self?.brokerSelectCoordinator = BrokerSelectCoordinator(presentingViewController: presentingController, transactionId: transactionId, transactionIntent: transactionIntent, completion: completion)
              self?.brokerSelectCoordinator.start()
          }
          
      }
    
    private func openBrokerSelect( presentingController: UIViewController, transactionId: String,transactionIntent:Bool, completion: @escaping (Result<TransactionIntent, TransactionError>) -> Void ) {
        DispatchQueue.main.async { [weak self] in
            self?.brokerSelectCoordinator = BrokerSelectCoordinator(presentingViewController: presentingController, transactionId: transactionId,transactionIntent: transactionIntent, completion: completion)
            self?.brokerSelectCoordinator.start()
        }
        
    }
    
    //MARK:- Initialize
    private override init() {}
    
}


