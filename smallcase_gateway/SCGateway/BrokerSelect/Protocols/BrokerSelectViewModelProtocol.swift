//
//  BrokerSelectViewModelProtocol.swift
//  SCGateway
//
//  Created by Ankit Deshmukh on 02/05/22.
//  Copyright © 2022 smallcase. All rights reserved.
//

import Foundation
import AuthenticationServices

protocol BrokerSelectViewModelProtocol: ConnectedConsentDelegate{
    
    @available(iOS 13.0, *)
    var webPresentationContextProvider: Any? {get set }
    
    var model: BrokerSelectModelProtocol? { get set}
    
    var coordinatorDelegate: BrokerSelectCoordinatorVMDelegate? { get set }
    
    var delegate: BrokerSelectVMDelegate? { get set }
    
    //    var upcomingBrokerSelectedDelegate: SelectUpcomingBrokerDelegate? {get set}
    
    var transactionId: String { get set }
    
    var userBrokerConfig: BrokerConfig? { get set }
    
    //    var numberOfItems: Int { get }
    
    var isLogout: Bool {get set}
    
    var showOrders: Bool {get set}
    
    func getBrokerConfig()
    
    func config(at index: Int) -> BrokerConfig?
    
    func getConnectedBrokerConfig (brokersConfigArray: [BrokerConfig]) -> BrokerConfig?
    
    func keyboardAppeared(height:CGFloat)
    
    func KeyboardDisappeared()
    
    func updateBroker(brokerConfig:BrokerConfig)
    
    init(model: BrokerSelectModelProtocol, transactionId: String,transactionIntent: Bool)
    
    func closeBrokerChooser()
    
    func launchBrokerPlatform(brokerName: String)
    
    func getBrokerChooserJSCommand() -> String
    
    func didTapSignup()
    
    func processBPRedirectionFromHostApp(withRedirectUrl: URL)
    
    func getAvailableBrokers() -> [String]?
    
    func getWebBrokerChooserUrl() -> URLRequest
    
    func launchNativeBrokerApp()
    
    func openGateway(url: URL?)
    
    func initiateTransactionWebView(transactionId: String, isNativeLogin: Bool?)
    
    func markTransactionErrored(_ error: TransactionError)
}
