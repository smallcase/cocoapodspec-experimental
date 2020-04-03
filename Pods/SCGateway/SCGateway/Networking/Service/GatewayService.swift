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
    case getTransactionStatus(trxid: String)
    case marketStatus
    case markTransactionErrored(trxId: String, error: TransactionError)
    
    // User data
    case getSmallcases(params: [String: Any])
    case getSmallcaseProfile(scid: String)
    case getNews(params: [String: Any])
    case getUserInvestments(iscids: [String]?)
    case getExitedSmallcases
    case getHistorical(params: [String: Any])
    
    
    private var baseUrlStr: String {
        switch self {
        case .getBrokerConfig:

            return "https://config.smallcase.com/"
            
        case .getGatewayCopy:
            switch Config.baseEnvironment {
            case .production:
                return "https://config.smallcase.com/gateway/copyConfig/production/"
            case .development:
                return "https://config.smallcase.com/gateway/copyConfig/development/"
            case .staging:
                return "https://config.smallcase.com/gateway/copyConfig/staging/"
         
            }
            
            
        default:
            switch Config.baseEnvironment {
            case  .production:
                return "https://gatewayapi.smallcase.com/gateway/\(Config.gatewayName!)/"
            case .staging:
                return "https://gatewayapi.stag.smallcase.com/gateway/\(Config.gatewayName!)/"
            case .development:
                return "https://gatewayapi-dev.smallcase.com/gateway/\(Config.gatewayName!)/"
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
            
        case let .getTransactionStatus(trxid):
            return ["transactionId": trxid]
            
        case let .markTransactionErrored(trxId, trxError):
            return [
                "transactionId": trxId,
                "status": "ERRORED",
                "errorCode": trxError.rawValue,
                "errorMessage": trxError.markErrorStatus ?? ""
            ]
            
        case let .getSmallcases(params):
            return params
            
        case let .getSmallcaseProfile(scid):
            return [ "scid": scid ]
            
        case let .getUserInvestments(iscids):
            
            guard let iscids = iscids else { return nil }
            return ["iscids": iscids]
            
        case let .getHistorical(params):
            return params
            
        case let .getNews(params):
            return params
            
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
            switch Config.baseEnvironment {
            case .production:
                return "brokerconfig/production/brokerConfig.json"
            case .development:
                return "brokerconfig/development/brokerConfig.json"
            case .staging:
                return "brokerconfig/staging/brokerConfig.json"
                
            }
            
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
            
        case .getUserInvestments:
            return "user/investments"
            
        case .getExitedSmallcases:
            return "user/exitedSmallcases"
            
        case .getHistorical:
            return "smallcase/chart"
            
        case .markTransactionErrored:
            return "transaction/markErrored"
            
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
            
        case .getUserInvestments:
            return .get
            
        case .getExitedSmallcases:
            return .get
            
        case .getHistorical:
            return .get
            
        case .markTransactionErrored:
            return .post
            
        }
    }
    
    var task: Task {
        if let params = parameters { return .requestParameters(params) }
        return .requestPlain
    }
    
    var headers: Headers? {
        
        var headerStruct = [
            "Content-Type": "application/json"
        ]
        
        if let token = Config.gatewayToken {
            headerStruct["x-sc-gateway"] = token
        }
        
        if let csrf = Config.csrfToken {
            headerStruct["x-sc-csrf"] = csrf
        }
        
        if var broker = Config.broker?.name {
            
            if broker.contains("-leprechaun") {
                broker = broker.replacingOccurrences(of: "-leprechaun", with: "")
            }
            
            headerStruct["x-sc-broker"] = broker
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
            
        case .getTransactionStatus:
            return .url
            
        case .marketStatus:
            return .url
            
        case .getSmallcases , .getSmallcaseProfile:
            return .url
            
        case .getNews:
            return .url
            
        case .getUserInvestments:
            return .json
            
        case .getExitedSmallcases:
            return .url
            
        case .getHistorical:
            return .url
            
        case .markTransactionErrored:
            return .json
            
        }
    }
    
    
}
