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
    
    @available(*, deprecated, message: "Use triggerInteraction() instead.")
    public func apply(presentingController: UIViewController, loanInfo: ScLoanInfo, completion: @escaping ((ScLoanResult<ScLoanSuccess>) -> Void)) {
        trigger(presentingController: presentingController, loanInfo: loanInfo.toInternal(methodIntent: .LOAN_APPLICATION), completion: completion)
    }

    @available(*, deprecated, message: "Use triggerInteraction() instead.")
    public func pay(presentingController: UIViewController, loanInfo: ScLoanInfo, completion: @escaping ((ScLoanResult<ScLoanSuccess>) -> Void)) {
        trigger(presentingController: presentingController, loanInfo: loanInfo.toInternal(methodIntent: .PAYMENT), completion: completion)
    }

    @available(*, deprecated, message: "Use triggerInteraction() instead.")
    public func withdraw(presentingController: UIViewController, loanInfo: ScLoanInfo, completion: @escaping ((ScLoanResult<ScLoanSuccess>) -> Void)) {
        trigger(presentingController: presentingController, loanInfo: loanInfo.toInternal(methodIntent: .WITHDRAW), completion: completion)
    }

    @available(*, deprecated, message: "Use triggerInteraction() instead.")
    public func service(presentingController: UIViewController, loanInfo: ScLoanInfo, completion: @escaping ((ScLoanResult<ScLoanSuccess>) -> Void)) {
        trigger(presentingController: presentingController, loanInfo: loanInfo.toInternal(methodIntent: .SERVICE), completion: completion)
    }
    
    public func triggerInteraction(presentingController: UIViewController, loanInfo: ScLoanInfo, completion: @escaping ((ScLoanResult<ScLoanSuccess>) -> Void)) {
        trigger(presentingController: presentingController, loanInfo: loanInfo.toInternal(), completion: completion)
    }

    private func trigger(presentingController: UIViewController, loanInfo: ScLoanInfoInternal, completion: @escaping ((ScLoanResult<ScLoanSuccess>) -> Void)) {
        SessionManager.loanInfo = loanInfo
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
                "methodIntent": loanInfo.methodIntent?.rawValue
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
