//
//  SCGateway+MF.swift
//  SCGateway
//
//  Created by Indrajit Roy on 08/09/22.
//  Copyright © 2022 smallcase. All rights reserved.
//

import Foundation

extension SCGateway {
    @available(*, deprecated, message: "Will be removed soon. Use triggerTransactionFlow instead.")
    public func triggerMfTransaction(presentingController: UIViewController, transactionId: String, completion: @escaping(Result<TransactionIntent, TransactionError>) -> Void) throws {
            
            print("------------------- Launching MF Holdings Import ------------------------")
        try triggerTransactionFlow(transactionId: transactionId, presentingController: presentingController, completion: completion)
    }
}

protocol WebViewTransactor {
    var transactionId: String {get}
    
    func setTransactionStatus(webException: WebException?)
}


class WebException : Error {
    var status: String?
    var code: Int
    var error: String
    init(status: String?, code: Int, error: String) {
        self.status = status
        self.code = code
        self.error = error
    }
    var isUserCancelled: Bool {
        get {
            return self.code == TransactionError.safariTabClosedInitialised.rawValue ||
            self.code == TransactionError.safariTabClosedUsed.rawValue
        }
    }
}
