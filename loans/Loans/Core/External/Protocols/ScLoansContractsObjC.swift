//
//  GatewayLoansContracts.swift
//  Loans
//
//  Created by Ankit Deshmukh on 21/04/23.
//

//import Foundation
import UIKit

protocol ScLoansContract {
    func setup(
        config: ScLoanConfig,
        completion: @escaping ((ScLoanResult<ScLoanSuccess>) -> Void)
    )
    
    func apply(
        presentingController: UIViewController,
        loanInfo: ScLoanInfo,
        completion: @escaping ((ScLoanResult<ScLoanSuccess>) -> Void)
    )
    
    func pay(
        presentingController: UIViewController,
        loanInfo: ScLoanInfo,
        completion: @escaping ((ScLoanResult<ScLoanSuccess>) -> Void)
    )
    
    func withdraw(
        presentingController: UIViewController,
        loanInfo: ScLoanInfo,
        completion: @escaping ((ScLoanResult<ScLoanSuccess>) -> Void)
    )

    func service(
        presentingController: UIViewController,
        loanInfo: ScLoanInfo,
        completion: @escaping ((ScLoanResult<ScLoanSuccess>) -> Void)
    )
    
    func triggerInteraction(
        presentingController: UIViewController,
        loanInfo: ScLoanInfo,
        completion: @escaping ((ScLoanResult<ScLoanSuccess>) -> Void)
    )
    
    func closeLoanAccount(
        presentingController: UIViewController,
        loanInfo: ScLoanInfo,
        completion: @escaping ((ScLoanResult<ScLoanSuccess>) -> Void)
    )
}

@objc protocol ScLoansContractsObjC {
    
    @objc func setup(
        config: ScLoanConfig,
        completion: @escaping(ScLoanSuccess?, ScLoanError?) -> Void)
    
    // LOS (Loan origination)
    
    @objc func apply(
        presentingController: UIViewController,
        loanInfo: ScLoanInfo,
        completion: @escaping(ScLoanSuccess?, ScLoanError?) -> Void)
    
    // LMS (Loan servicing)
    
    @objc func pay(
        presentingController: UIViewController,
        loanInfo: ScLoanInfo,
        completion: @escaping(ScLoanSuccess?, ScLoanError?) -> Void)
    
    @objc func withdraw(
        presentingController: UIViewController,
        loanInfo: ScLoanInfo,
        completion: @escaping(ScLoanSuccess?, ScLoanError?) -> Void)
    
    @objc func service(
        presentingController: UIViewController,
        loanInfo: ScLoanInfo,
        completion: @escaping(ScLoanSuccess?, ScLoanError?) -> Void)
    
    @objc func closeLoanAccount(
        presentingController: UIViewController,
        loanInfo: ScLoanInfo,
        completion: @escaping(ScLoanSuccess?, ScLoanError?) -> Void)
}
