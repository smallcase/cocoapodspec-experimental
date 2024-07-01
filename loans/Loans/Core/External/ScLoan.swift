//
//  LoanAgainstSecurities.swift
//  Loans
//
//  Created by Ankit Deshmukh on 21/04/23.
//

import Foundation
import UIKit

public class ScLoan : NSObject, ScLoansContract {
    
    @objc public static let instance = ScLoan()
    
    private var lasCoordinator: LASCoordinator? = nil
    
    private let cmsRepo: CMSRepositoryProtocol = CMSRepository()
    
    internal var mixpanelSetupInProgress = false
    internal var mixpanelSetupComplete = false
    
    private var isInitialised: Bool {
        get {
            return (SessionManager.gatewayName != nil)
        }
    }
    //Network
    private let unityAPI: UnityAPI = UnityAPI()
    internal let cmsAPI: CMSAPI = CMSAPI()
    
    /**
     * 1. Fetch the remote config for copy + any other static data
     * 2. Respond back with success or error
     */
    
    public func setup(config: ScLoanConfig, completion: @escaping ((ScLoanResult<ScLoanSuccess>) -> Void)) {
        registerAllFonts()
        SessionManager.gatewayName = config.gatewayName
        SessionManager.baseEnvironment = config.environment ?? .production
        setupMixpanel()
        cmsRepo.loadLenderConfig(completion: completion)
    }
    
    public func apply(presentingController: UIViewController, loanInfo: ScLoanInfo, completion: @escaping ((ScLoanResult<ScLoanSuccess>) -> Void)) {
        trigger(presentingController: presentingController, loanInfo: loanInfo, methodIntent: .LOAN_APPLICATION, completion: completion)
    }

    public func pay(presentingController: UIViewController, loanInfo: ScLoanInfo, completion: @escaping ((ScLoanResult<ScLoanSuccess>) -> Void)) {
        trigger(presentingController: presentingController, loanInfo: loanInfo, methodIntent: .PAYMENT, completion: completion)
    }

    public func withdraw(presentingController: UIViewController, loanInfo: ScLoanInfo, completion: @escaping ((ScLoanResult<ScLoanSuccess>) -> Void)) {
        trigger(presentingController: presentingController, loanInfo: loanInfo, methodIntent: .WITHDRAW, completion: completion)
    }

    public func service(presentingController: UIViewController, loanInfo: ScLoanInfo, completion: @escaping ((ScLoanResult<ScLoanSuccess>) -> Void)) {
        trigger(presentingController: presentingController, loanInfo: loanInfo, methodIntent: .SERVICE, completion: completion)
    }

    private func trigger(presentingController: UIViewController, loanInfo: ScLoanInfo, methodIntent: ScLoanIntent, completion: @escaping ((ScLoanResult<ScLoanSuccess>) -> Void)) {
        SessionManager.loanInfo = loanInfo.toInternal(methodIntent: methodIntent)
        if !isInitialised {
            self.registerMixpanelEvent(
                eventName: MixpanelConstants.EVENT_RESPONSE_SENT_TO_PARTNER,
                additionalProperties: [
                    "code": ScLoanError.initSdkError.code,
                    "message": ScLoanError.initSdkError.errorMessage,
                    "data": ScLoanError.initSdkError.data
                ])
            completion(.failure(ScLoanError.initSdkError))
            return
        }
        self.lasCoordinator = LASCoordinator(presentingController, completion)
        self.registerMixpanelEvent(
            eventName: MixpanelConstants.EVENT_TRIGGERED_INTERACTION,
            additionalProperties: [
                "methodIntent": methodIntent.rawValue
            ])
        lasCoordinator?.launchLoadingScreen()
    }

    func closeLoanAccount(presentingController: UIViewController, loanInfo: ScLoanInfo, completion: @escaping ((ScLoanResult<ScLoanSuccess>) -> Void)) {
    }
    
    private func registerAllFonts() {
        UIFont.jbs_registerFont(
            withFilenameString: "GraphikApp-Bold.ttf",
            bundle: Bundle(for: ScLoan.self)
        )
        UIFont.jbs_registerFont(
            withFilenameString: "GraphikApp-Light.ttf",
            bundle: Bundle(for: ScLoan.self)
        )
        UIFont.jbs_registerFont(
            withFilenameString: "GraphikApp-Medium.ttf",
            bundle: Bundle(for: ScLoan.self)
        )
        UIFont.jbs_registerFont(
            withFilenameString: "GraphikApp-MediumItalic.ttf",
            bundle: Bundle(for: ScLoan.self)
        )
        UIFont.jbs_registerFont(
            withFilenameString: "GraphikApp-Regular.ttf",
            bundle: Bundle(for: ScLoan.self)
        )
        UIFont.jbs_registerFont(
            withFilenameString: "GraphikApp-RegularItalic.ttf",
            bundle: Bundle(for: ScLoan.self)
        )
        UIFont.jbs_registerFont(
            withFilenameString: "GraphikApp-Semibold.ttf",
            bundle: Bundle(for: ScLoan.self)
        )
    }
    
}
