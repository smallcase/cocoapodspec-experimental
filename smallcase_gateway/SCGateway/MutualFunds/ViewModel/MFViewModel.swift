//
//  MFViewModel.swift
//  SCGateway
//
//  Created by Indrajit Roy on 08/09/22.
//  Copyright © 2022 smallcase. All rights reserved.
//

import Foundation

class MFViewModel: NSObject, WebViewTransactor {
    
    internal static let sessionVariantToBaseUrl = [
        Environment.development : "gateway-dev.smallca.se",
        Environment.staging : "gateway-stag.smallca.se",
        Environment.production : "gateway.smallca.se",
    ]
    let endpoint = "mutualfunds/import/"
    
    var transactionId: String
    let completion: (SdkPartnerResponse) -> Void
    var state : MFViewController.State = MFViewController.State.Idle {
        didSet {
            switch state {
            case .TxnResponseSentToPartner(let response):
                completion(response)
            case .WebViewErrored, .WebViewClosedByBackButton :
                setTransactionStatus(webException: nil)
            default : return
            }
        }
    }
    
    init(transactionId: String, completion: @escaping (SdkPartnerResponse) -> Void) {
        self.transactionId = transactionId
        self.completion = completion
    }
    
    func getUrl() -> URLRequest {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = MFViewModel.sessionVariantToBaseUrl[SessionManager.baseEnvironment]
        urlComponents.path = "/" + endpoint
        let queryItems = [
            URLQueryItem(name: "transactionId", value: transactionId),
            URLQueryItem(name: "gateway", value: SessionManager.gatewayName ?? ""),
            URLQueryItem(name: "clientType", value: "ios"),
        ]
        urlComponents.queryItems = queryItems
        print("MFViewModel: getUrl: \(urlComponents)")
        return URLRequest(url: urlComponents.url!)
    }
    
    func processDispatchMessage(message: String) {
        let dispatchMessage = DispatchMessage.fromRaw(message: message)
        dispatchMessage?.process(webViewTransactor: self)
    }
    
    func setTransactionStatus(webException: WebException?) {
        SCGateway.shared.fetchMfTransactionStatus(transactionId: transactionId) { [weak self] (result) in
            switch result {
            case .success(let response):
                let txnStatus = response.data
                if(txnStatus != nil) {
                    let mfResponse = getMfResponse(mfTransactionStatus: txnStatus!, webException: webException)
                    self?.state = MFViewController.State.TxnResponseSentToPartner(mfResponse)
                }
            case .failure(_):
                let mfResponse = MFErrorResponse(txnError: .apiError)
                self?.state = MFViewController.State.TxnResponseSentToPartner(mfResponse)
            }
        }
    }
}

func getMfResponse(mfTransactionStatus: MFTransactionStatusResponse.MFTransactionData, webException: WebException?) -> SdkPartnerResponse {
    if(webException?.isUserCancelled == true) {
        let e = TransactionError.dynamicError(msg: webException!.error, code: webException!.code, data: nil)
        return MFErrorResponse(txnError: e)
        
    }
    if(mfTransactionStatus.transaction?.isSuccess == true) {
        let data = [
            "transactionId" : mfTransactionStatus.transaction?.transactionId,
            "notes" : mfTransactionStatus.transaction?.success?.notes
        ].toJsonString
        return MFSuccessResponse(data: data)
    }
    if (mfTransactionStatus.transaction?.isError == true) {
        let e = TransactionError.dynamicError(msg: mfTransactionStatus.transaction?.error?.message ?? "", code: mfTransactionStatus.transaction?.error?.code ?? 0, data: nil)
        return MFErrorResponse(txnError: e)
    }
    if (webException != nil) {
        let e = TransactionError.dynamicError(msg: webException!.error, code: webException!.code, data: nil)
        return MFErrorResponse(txnError: e)
    }
    
    if (mfTransactionStatus.transaction?.status == TransactionOrderStatus.initialized.rawValue) {
        return MFErrorResponse(txnError: .safariTabClosedInitialised)
    }
    if (mfTransactionStatus.transaction?.status == TransactionOrderStatus.used.rawValue) {
        return MFErrorResponse(txnError: .safariTabClosedUsed)
    }
    return MFErrorResponse(txnError: .apiError)
}
