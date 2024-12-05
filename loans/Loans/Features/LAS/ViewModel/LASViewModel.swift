//
//  LASViewModel.swift
//  Loans
//
//  Created by Ankit Deshmukh on 06/05/23.
//

import Foundation
import AuthenticationServices

class LASViewModel: NSObject, LASViewModelProtocol {
    
    var viewControllerDelegate: ViewModelUIViewControllerDelegate?
    var coordinatorDelegate: LASCoordinatorVMDelegate?
    
    //For web auth session
    internal var webPresentationContextProvider: Any? = nil
    internal var gatewaySFAuthenticationProvider: GatewaySFAuthenticationProvider? = nil
    internal var gatewayASWebAuthenticationProvider: Any? = nil
    
    private let unityAPI: UnityAPI = UnityAPI()
    private var lenderInfo: LenderInfo?
    
    func getLenderInfo() -> LenderInfo? {
        return self.lenderInfo
    }
    
    private var baseUrlString: String {
        
        switch SessionManager.baseEnvironment {
            case .production:
//                return "https://unity.las.smallcase.com/client/\(SessionManager.gatewayName!)"
            return "https://api.unity.smallcase.com/client/\(SessionManager.gatewayName!)"
            case .staging:
                return "https://api-stag.unity.smallcase.com/client/\(SessionManager.gatewayName!)"
            case .development:
//                return "https://5fa7-2405-201-d022-e98c-b414-9b17-1eb8-b998.ngrok-free.app/client/\(SessionManager.gatewayName!)"
                return "https://unity-dev.las.smallcase.com/client/\(SessionManager.gatewayName!)"
        }
    }
    
    func authenticateInteraction() {
        guard let currentLoanInfo = SessionManager.loanInfo else { 
            self.handleError(ScLoanError.internalError)
            return }
        let interactionToken = currentLoanInfo.interactionToken
        
        DispatchQueue.global(qos: .default).async {
            self.unityAPI.initialiseInteraction(interactionToken) { [weak self] response, error in
                guard let self = self else { 
                    self?.handleError(ScLoanError.internalError)
                    return }
                
                if let error = error {
                    self.handleError(error)
                    return
                }
                
                guard let response = response,
                      let resDict = response.toJson(),
                      let code = resDict["code"] as? Int else {
                    self.handleError(ScLoanError.internalError)
                    return
                }
                
                if code == 0 {
                    self.handleSuccess(resDict, currentLoanInfo: currentLoanInfo)
                } else {
                    self.handleAPIError(resDict)
                }
            }
        }
    }

    private func handleError(_ error: Error) {
        coordinatorDelegate?.concludeLOSJourney(.failure(ScLoanError.internalError))
    }

    private func handleSuccess(_ resDict: [String: Any], currentLoanInfo: ScLoanInfoInternal) {
        guard let resData = resDict["data"] as? [String: Any] else { return }
        
        let lenderInfo = LenderInfo(
            resData["lenderName"] as! String,
            resData["url"] as! String,
            resData["openPlatform"] as! Bool,
            resData["intent"] as! String,
            (resData["isAuthRequired"] as? Bool) ?? false,
            (resData["productType"] as? String) ?? "lamf"
        )
        SessionManager.currentlenderInfoMap[currentLoanInfo.interactionToken] = lenderInfo
        
        ScLoan.instance.registerMixpanelEvent(eventName: MixpanelConstants.EVENT_INTERACTION_INITIALISED,
                                              additionalProperties: [
                                                "intent": lenderInfo.intent,
                                                "url": lenderInfo.losUrl,
                                                "openPlatform": lenderInfo.openPlatform,
                                                "isAuthRequired": lenderInfo.isAuthRequired
                                              ])
        
        // To support newer intents, we have added a new function triggerInteraction which does not take any specific methodIntent as input hence this code will only check for those conditions where methodIntent is specified.
        if let methodIntent = currentLoanInfo.methodIntent {
            let isValidIntent = lenderInfo.intent == methodIntent.rawValue ||
                                methodIntent.subIntents.contains(lenderInfo.intent)
            
            guard isValidIntent else {
                coordinatorDelegate?.concludeLOSJourney(.failure(ScLoanError.invalidInteractionIntent))
                return
            }
        }

       
        
        self.lenderInfo = lenderInfo
        
        if lenderInfo.openPlatform {
            viewControllerDelegate?.updateState(showLoadingView: lenderInfo.intent.lowercased() == "loan_application")
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.makeAPICallToBEURL()
            }
        }
    }

    private func handleAPIError(_ resDict: [String: Any]) {
        if let errorMessage = resDict["message"] as? String,
           let code = resDict["code"] as? Int {
            coordinatorDelegate?.concludeLOSJourney(.failure(ScLoanError(errorCode: code, errorMessage: errorMessage)))
        } else {
            coordinatorDelegate?.concludeLOSJourney(.failure(ScLoanError.internalError))
        }
    }

    
    func launchLOSJourney() {
        
        guard let lenderInfo = self.lenderInfo else {
            self.coordinatorDelegate?.concludeLOSJourney(.failure(ScLoanError.internalError))
            return
        }
        
        if lenderInfo.openPlatform {
            launchSafariCustomTab()
        } else {
            makeAPICallToBEURL()
        }
    }
    
    private func makeAPICallToBEURL() {
        guard let lenderURL = self.lenderInfo?.losUrl else {
            self.coordinatorDelegate?.concludeLOSJourney(.failure(ScLoanError.internalError))
            return
        }
        
        DispatchQueue.global(qos: .default).async {
            self.unityAPI.triggerLoanServicing(with: self.baseUrlString.appending(lenderURL)) { response, error in
                ScLoan.instance.registerMixpanelEvent(eventName: MixpanelConstants.EVENT_UNITY_API_CALLED, additionalProperties: [
                    "url": self.baseUrlString.appending(lenderURL)
                ])
                self.shareResponseToHost(response, error)
            }
        }
    }
    
    private func launchSafariCustomTab() {
        guard let url = URL(string: self.lenderInfo!.losUrl) else {return}
        
        if #available(iOS 13.0, *) {
            gatewaySFAuthenticationProvider = nil
            
            gatewayASWebAuthenticationProvider = GatewayASWebAuthenticationProvider(
                url,
                GatewayLoanConstants.callbackUrlScheme,
                webPresentationContextProvider as? ASWebAuthenticationPresentationContextProviding,
                isPrivateSession: lenderInfo == nil ? true : !(lenderInfo!.isAuthRequired),
                completionHandler: { [weak self] responseURL, error in
                    
                    guard let self = self else { return }
                    ScLoan.instance.registerMixpanelEvent(eventName: MixpanelConstants.EVENT_LOANS_PLATFORM_RESPONSE_RECEIVED, additionalProperties: [
                        "url": responseURL
                    ])
                    self.handleRedirectionFromWeb(responseURL, error)
            })
            
            if let gatewayAuthProvider = self.gatewayASWebAuthenticationProvider as? GatewayASWebAuthenticationProvider, gatewayAuthProvider.start() {
                ScLoan.instance.registerMixpanelEvent(eventName: MixpanelConstants.EVENT_LOANS_PLATFORM_LAUNCHED, additionalProperties: [
                    "url": self.lenderInfo?.losUrl
                ])
                print("-------------------- LOS Journey started --------------------------")
            }
            
        } else {
            
            gatewaySFAuthenticationProvider = GatewaySFAuthenticationProvider(
                url,
                GatewayLoanConstants.callbackUrlScheme,
                completionHandler: { [weak self] responseURL, error in
                    
                    guard let self = self else { return }
                    self.handleRedirectionFromWeb(responseURL, error)
                    
                })
            
            if gatewaySFAuthenticationProvider!.start() {
                ScLoan.instance.registerMixpanelEvent(eventName: MixpanelConstants.EVENT_LOANS_PLATFORM_LAUNCHED, additionalProperties: [
                    "url": self.lenderInfo?.losUrl
                ])
                print("-------------------- LOS Journey started --------------------------")
            }
        }
    }
    
    private func handleRedirectionFromWeb(_ feDeepLink: URL?, _ err: Error?) {
        
        guard let interactionToken = SessionManager.loanInfo?.interactionToken else {return}
        
        var feStatus = extractInteractionStatusFromFEDeeplink(feDeepLink?.query)
        
        if err != nil {
            feStatus = (false, ScLoanError.userCancelledError.errorCode, ScLoanError.userCancelledError.errorMessage)
        }
        
        getInteractionStatusAndShareResponse(
            interactionToken,
            feStatus.errorCode,
            feStatus.errorMessage
        )
    }
    
    private func extractInteractionStatusFromFEDeeplink(_ queryParam: String?) -> (success: Bool?, errorCode: Int?, errorMessage:String?) {
        
        guard let query = queryParam else {
            return (nil, nil, nil)
        }
        
        let queryComponents = query.components(separatedBy: "&")
        var _success: Bool = false
        var _errorCode: Int = -1
        var _errorMessage: String =  ""
        
        queryComponents.forEach { (component) in
            if component.contains("success") {
                _success = Bool(component.components(separatedBy: "=").last ?? "false")!
            }
            
            if component.contains("message") {
                _errorMessage = component.components(separatedBy: "=").last ?? ""
            }
            
            if component.contains("code") {
                _errorCode = Int(component.components(separatedBy: "=").last ?? "-1") ?? -1
            }
            
        }
        
        return (_success, _errorCode, _errorMessage)
    }
    
    private func getInteractionStatusAndShareResponse(_ interactionToken: String, _ code: Int?, _ message: String?) {
        DispatchQueue.global(qos: .default).async {
            self.unityAPI.getInteractionStatus(interactionToken, code, message) { response, error in
                self.shareResponseToHost(response, error)
            }
        }
    }
    
    private func shareResponseToHost(_ response: Data?, _ error: Error?) {
        
        if error != nil {
            self.coordinatorDelegate?.concludeLOSJourney(.failure(ScLoanError.internalError))
        } else {
            if let res = response, let resDict = res.toJson(), let code = resDict["code"] as? Int {
                
                ///check if status code is 0, else it is an error
                if(code == 0) {
                    if let resData = resDict["data"] as? [String: Any] {
                        let successResponse: ScLoanSuccess = ScLoanSuccess(data: resData.toJsonString, code: resDict["code"] as? Int ?? 0, message: resDict["message"] as? String ?? "success")
                        self.coordinatorDelegate?.concludeLOSJourney(.success(successResponse))
                        return
                    }
                } else {
                    if let errorMessage = resDict["message"] as? String {
                        var errorData: [String: Any]? = nil
                        
                        if let resData = resDict["data"] as? [String: Any] {
                            errorData = resData
                        }
                        self.coordinatorDelegate?.concludeLOSJourney(
                            .failure(ScLoanError(
                                errorCode: code,
                                errorMessage: errorMessage,
                                data: errorData?.toJsonString
                            )))
                    }
                }
            } 
            else {
                let resDict = response?.toJson()
                self.coordinatorDelegate?.concludeLOSJourney(.failure(ScLoanError(errorCode: ScLoanError.internalError.code, errorMessage: ScLoanError.internalError.errorMessage, data:
                    ["debugSectionTag": "shareResponseToHost:: if,else^ > if,else^",
                     "debugRes": "\(response)",
                     "debugResDict": "\(response?.toJson())",
                     "debugCode": resDict?["code"]
                    ].toJsonString)))
            }
        }
    }
    
}
