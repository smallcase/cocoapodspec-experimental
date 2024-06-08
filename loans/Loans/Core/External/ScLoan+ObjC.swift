//
//  SCLoans+ObjC.swift
//  Loans
//
//  Created by Indrajit Roy on 06/10/23.
//

import Foundation
import UIKit

extension ScLoan: ScLoansContractsObjC {
    
    @objc public func setup(config: ScLoanConfig, completion: @escaping(ScLoanSuccess?, ScLoanError?) -> Void) {
        setup(config: config) {
            result in
            switch(result) {
            case .success(let response):
                completion(response, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    @objc public func apply(presentingController: UIViewController, loanInfo: ScLoanInfo, completion: @escaping(ScLoanSuccess?, ScLoanError?) -> Void) {
        apply(presentingController: presentingController, loanInfo: loanInfo) {
            result in
            switch(result) {
            case .success(let response):
                completion(response, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    @objc public func pay(presentingController: UIViewController, loanInfo: ScLoanInfo, completion: @escaping(ScLoanSuccess?, ScLoanError?) -> Void) {
        pay(presentingController: presentingController, loanInfo: loanInfo) {
            result in
            switch(result) {
            case .success(let response):
                completion(response, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    @objc public func withdraw(presentingController: UIViewController, loanInfo: ScLoanInfo, completion: @escaping(ScLoanSuccess?, ScLoanError?) -> Void) {
        withdraw(presentingController: presentingController, loanInfo: loanInfo) {
            result in
            switch(result) {
            case .success(let response):
                completion(response, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    @objc public func service(presentingController: UIViewController, loanInfo: ScLoanInfo, completion: @escaping(ScLoanSuccess?, ScLoanError?) -> Void) {
        service(presentingController: presentingController, loanInfo: loanInfo) {
            result in
            switch(result) {
            case .success(let response):
                completion(response, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    //TO be implemented
    func closeLoanAccount(presentingController: UIViewController, loanInfo: ScLoanInfo, completion: @escaping (ScLoanSuccess?, ScLoanError?) -> Void) {
        
    }
}
