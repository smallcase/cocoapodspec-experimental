//
//  GatewayService.swift
//  SCGateway
//
//  Created by Shivani on 06/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//



enum GatewayService: ServiceProtocol {
    
    case initializeSession(smallcaseAuthToken: String)
    case getTransactionRequest(urlEndpoint: String)
    case getBrokerConfig
    case getBrokerRedirectParams(txId: String, brokerName: String)
    case getGatewayCopy
    case getTweetConfig
    case getPartnerConfig
    case getTransactionStatus(trxid: String)
    case getFivePaisaLead(email: String, source: String)
    case marketStatus
    case markTransactionErrored(trxId: String, error: TransactionError)
    case markSmallcaseArchive(params: [String: Any])
    
    // User data
    case getSmallcases(params: [String: Any])
    case getSmallcaseProfile(scid: String)
    case getNews(params: [String: Any])
    case getUserInvestments(iscids: [String]?)
    case getUserInvestmentDetails(iscid: String?)
    case getExitedSmallcases
    case getHistorical(params: [String: Any])
    case updateBroker(trnxId: String , broker:String)
    case updateDeviceType(trnxId: String , device: String)
    case updateConsent(trnxId:String)
    
    // USE Account Opening
    case getUSELeadStatus(leadId: String? = nil, opaqueId: String? = nil)
    case getMobileConfig
    
    private var baseUrlStr: String {
        switch self {
                
            case .getMobileConfig:
                switch SessionManager.baseEnvironment {
                    case .production:
                        return "https://config.smallcase.com/gateway/mobileConfig/production/"
                    case .development:
                        return "https://config.smallcase.com/gateway/mobileConfig/development/"
                    case .staging:
                        return "https://config.smallcase.com/gateway/mobileConfig/staging/"
                        
                }
                
            case .getBrokerConfig:

            return "https://config.smallcase.com/"
            
        case .getGatewayCopy:
            switch SessionManager.baseEnvironment {
            case .production:
                return "https://config.smallcase.com/gateway/copyConfig/production/"
            case .development:
                return "https://config.smallcase.com/gateway/copyConfig/development/"
            case .staging:
                return "https://config.smallcase.com/gateway/copyConfig/staging/"
         
            }
            
        case .getTweetConfig:
            switch SessionManager.baseEnvironment {
            case .staging:
                return "https://config.smallcase.com/brokerconfig/staging/"
            case .development:
                return "https://config.smallcase.com/brokerconfig/development/"
            default:
                return "https://config.smallcase.com/brokerconfig/production/"
            }
            
            
        default:
            switch SessionManager.baseEnvironment {
            case  .production:
                return "https://gatewayapi.smallcase.com/gateway/\(SessionManager.gatewayName!)/"
            case .staging:
                return "https://gatewayapi-stag.smallcase.com/gateway/\(SessionManager.gatewayName!)/"
            case .development:
                return "https://gatewayapi-dev.smallcase.com/gateway/\(SessionManager.gatewayName!)/"
            }
            
        }
        
    }
    
    private var parameters: Parameters? {
        switch self {
        case  let .initializeSession(smallcaseAuthToken) :
            return ["sdkToken": smallcaseAuthToken]
            
        case let .getTransactionRequest(txId):
            return ["id": txId]
            
        case let .getBrokerRedirectParams(urlEndpoint, brokerName):
            
            return [
                "url": urlEndpoint,
                "broker": brokerName
            ]
            
        case let .getFivePaisaLead(email, source):
            
            return [
                "email": email,
                "source": source
            ]
            
        case let .getTransactionStatus(trxid):
            return ["transactionId": trxid]
            
        case let .markTransactionErrored(trxId, trxError):
            let res = [
                "transactionId": trxId,
                "status": "ERRORED",
                "errorCode":  trxError.rawValue,
                "errorMessage": trxError.markErrorStatus ?? ""
                ] as [String : Any]
            print(res)
          return res
            
        case let .getSmallcases(params):
            return params
            
        case let .getSmallcaseProfile(scid):
            return [ "scid": scid ]
            
        case let .markSmallcaseArchive(params):
            return params

        case let .getUserInvestments(iscids):
            
            guard let iscids = iscids else { return nil }
                return ["iscid": iscids]
        
        case let .getUserInvestmentDetails(iscid):
            guard let iscid = iscid else { return nil}
                return ["iscid": iscid ]
                
        case let .getHistorical(params):
            return params
            
        case let .getNews(params):
            return params
            
        case let .updateDeviceType(trnxId,device):
            return ["transactionId": trnxId,
                    "update": ["agent" : device]]
            
        case let .updateBroker(trnxId, broker):
            return ["transactionId": trnxId,
            "update": ["broker" : broker]]
            
        case let .updateConsent(trnxId):
            return ["transactionId": trnxId,
                    "update": ["consent" : true]]
        
            case let .getUSELeadStatus(leadId, opaqueId):
                if leadId != nil {
                    return ["leadId": leadId!]
                } else {
                    return ["opaqueId": opaqueId!]
                }
                
                
        default:
            return nil
        }
    }
    
    var baseURL: URL {
        return URL(string: baseUrlStr)!
    }
    
    var path: String {
        switch self {
        case .initializeSession:
            return "initSession"
            
        case .getTransactionRequest:
            return "transaction"
            
        case .getBrokerConfig:
            switch SessionManager.baseEnvironment {
            case .production:
                return "brokerconfig/production/brokerConfig.json"
            case .development:
                return "brokerconfig/development/brokerConfig.json"
            case .staging:
                return "brokerconfig/staging/brokerConfig.json"
            }
        
        case .getTweetConfig:
            return "tweetConfig.json"
        case .getBrokerRedirectParams:
            return "brokerRedirectParams"
            
        case .getGatewayCopy:
            return "copyConfig.json"
            
        case .getTransactionStatus:
            return "transaction"
            
        case .marketStatus:
            return "market/checkStatus"
            
        case .getSmallcases:
            return "smallcases"
            
        case .getSmallcaseProfile:
            return "smallcase"
            
        case .getNews:
            return "smallcase/news"
            
        case .getUserInvestments, .getUserInvestmentDetails:
            return "user/investments"
            
        case .getExitedSmallcases:
            return "user/exitedSmallcases"
            
        case .getHistorical:
            return "smallcase/chart"
            
        case .markTransactionErrored:
            return "transaction/markErrored"
            
        case .updateBroker:
            return "transaction/update"
            
        case .updateDeviceType:
            return "transaction/update"
            
        case .updateConsent:
            return "transaction/update"
            
        case .getPartnerConfig:
            return "partnerConfig"
            
        case .getFivePaisaLead:
            return "5paisaPwa/token"
            
        case .markSmallcaseArchive:
            return "user/cancelBatch"
                
        case .getUSELeadStatus:
            return "v2/sdk/useao/status"
            
        case .getMobileConfig:
            return "mobileConfig.json"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .initializeSession:
            return .post
            
        case .getTransactionRequest:
            return .get
            
        case .getBrokerConfig:
            return .get
            
        case .getTweetConfig:
            return .get
        case .getBrokerRedirectParams:
            return .get
            
        case .getGatewayCopy:
            return .get
            
        case .getTransactionStatus:
            return .get
            
        case .marketStatus:
            return .get
            
        case .getSmallcases, .getSmallcaseProfile:
            return .get
            
        case .getNews:
            return .get
            
        case .getUserInvestments, .getUserInvestmentDetails:
            return .get
            
        case .getExitedSmallcases:
            return .get
            
        case .getHistorical:
            return .get
            
        case .markTransactionErrored:
            return .post
        
        case .updateDeviceType:
            return .post
            
        case .updateBroker:
            return .post
            
        case .updateConsent:
            return .post
            
        case .getPartnerConfig:
            return .get
                
        case .getFivePaisaLead:
            return .get
            
        case .markSmallcaseArchive:
            return .post

        case .getUSELeadStatus:
            return .get
                
        case .getMobileConfig:
            return .get
        }
    }
    
    var task: ScTask {
        if let params = parameters { return .requestParameters(params) }
        return .requestPlain
    }
    
    var headers: Headers? {
        
        var headerStruct = [
            "Content-Type": "application/json"
        ]
        
        if let token = SessionManager.sdkToken {
            if path == "5paisaPwa/token" || path == "/v2/sdk/useao/status" {
                headerStruct["x-sc-gateway"] = SessionManager.gatewayToken ?? ""
            } else {
                headerStruct["x-sc-gateway"] = token
            }
        }
        
        if let csrf = SessionManager.csrfToken {
            headerStruct["x-sc-csrf"] = csrf
        }
        
        if SessionManager.hybridSDKVersion != nil && SessionManager.sdkType != "ios" {
            headerStruct["x-sc-sdk-version"] = "ios:\(SCGateway.shared.getSdkVersion()),\(SessionManager.sdkType):\(SessionManager.hybridSDKVersion!)"
        } else {
             headerStruct["x-sc-sdk-version"] = "ios:\(SCGateway.shared.getSdkVersion())"
        }
        
        if let broker = SessionManager.broker?.name {
            
            //if broker.contains("-leprechaun") {
             //   broker = broker.replacingOccurrences(of: "-leprechaun", with: "")
            //}
            var sanitizedBroker = broker
            
            if SessionManager.isLeprechaunActive && !broker.contains("-leprechaun") {
                sanitizedBroker = broker + "-leprechaun"
            }
            headerStruct["x-sc-broker"] = sanitizedBroker
        }else if let broker = SessionManager.currentlySelectedBroker?.name {
            var sanitizedBroker = broker
            
            if SessionManager.isLeprechaunActive && !broker.contains("-leprechaun") {
                sanitizedBroker = broker + "-leprechaun"
            }
            headerStruct["x-sc-broker"] = sanitizedBroker
        }
        
        print("HEADERS: \(headerStruct)")
        return headerStruct
    }
    
    var parameterEncoding: ParametersEncoding {
        
        switch self {
        case .initializeSession:
            return .json
            
        case .getTransactionRequest:
            return .json
            
        case .getBrokerConfig:
            return .url
            
        case .getBrokerRedirectParams:
            return .url
            
        case .getGatewayCopy:
            return .url
            
        case .getTweetConfig:
            return .url
            
        case .getPartnerConfig:
            return .url
            
        case .getTransactionStatus:
            return .url
            
        case .marketStatus:
            return .url
            
        case .getSmallcases , .getSmallcaseProfile:
            return .url
            
        case .getNews:
            return .url
            
        case .getUserInvestments, .getUserInvestmentDetails:
            return .url
            
        case .getExitedSmallcases:
            return .url
            
        case .getHistorical:
            return .url
            
        case .markTransactionErrored:
            return .json
            
        case .updateDeviceType:
            return .json
            
        case .updateBroker:
            return .json
            
        case .updateConsent:
            return .json
            
        case .getFivePaisaLead:
            return .url
            
        case .markSmallcaseArchive:
            return .json

        case .getUSELeadStatus(leadId: let leadId):
            return .url
        
        case .getMobileConfig:
            return .url
        }
    }
    
    
}
