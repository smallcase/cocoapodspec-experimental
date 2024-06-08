//
//  GatewayService.swift
//  Loans
//
//  Created by Ankit Deshmukh on 06/05/23.
//

import Foundation

enum UnityService: ServiceProtocol {

    //MARK: Endpoints
    /**
     * This API will run the basic validations on the interaction (about the validity) and return the basic info of an interaction based on which the SDK will trigger the flow.
     */
    case interactionInit(_ interactionId: String)

    /**
     * This API will return the status of interaction using which the final response will be returned to the partner.*
     */
    case interactionStatus(_ interactionId: String, _ feCode: Int? = nil, _ feMessage: String? = nil)
    
    case loanServicing(_ endpoint: String)
    
    //MARK: Base URL
    private var baseUrlString: String {
        switch SessionManager.baseEnvironment {
            case .production:
//                return "https://unity.las.smallcase.com/client/\(SessionManager.gatewayName!)/v1"
            return "https://api.unity.smallcase.com/client/\(SessionManager.gatewayName!)/v1"
            case .staging:
                return "https://api-stag.unity.smallcase.com/client/\(SessionManager.gatewayName!)/v1"
            case .development:
                return "https://api-dev.unity.smallcase.com/client/\(SessionManager.gatewayName!)/v1"
//            return "https://5fa7-2405-201-d022-e98c-b414-9b17-1eb8-b998.ngrok-free.app/client/\(SessionManager.gatewayName!)/v1"
        }

    }
    
    var baseURL: URL {
        switch self {
        case .loanServicing(let endpoint):
            return URL(string: endpoint)!
        default:
            return URL(string: baseUrlString)!
        }
    }
    
    //MARK: Path
    var path: String? {
        switch self {
            case .interactionInit:
                return "/interaction/init"
                
            case .interactionStatus:
            return "/interaction"
            
            default: return nil
        }
    }
    
    //MARK: Request Type
    var method: HTTPMethod {
        switch self {
            default:
                return .post
        }
    }
    
    //MARK: Parameters
    private var parameters: Parameters? {
        switch self {
        case .interactionStatus(_, let feCode, let feMessage):
            
            if let code = feCode, let message = feMessage {
                let paramDict =  [
                    "message": message,
                    "code": code
                ] as [String : Any]
                print(paramDict.toJsonString!)
                return paramDict
            } else {
                return nil
            }

            default:
                return nil
        }
    }
    
    var task: Task {
        if let params = parameters { return .requestParameters(params) }
        return .requestPlain
    }
    
    //MARK: Headers
    var headers: Headers? {
        
        var headerStruct = [
            "Content-Type": "application/json",
            "x-gateway-sdk-type": "ios"
        ]
        
        if let interactionToken = SessionManager.loanInfo?.interactionToken {
            headerStruct["x-gateway-interaction"] = interactionToken
        }
        
        //TODO: add header SDK type
        
        if SessionManager.hybridSdkVersion != nil && SessionManager.sdkType != "ios" {
            headerStruct["x-gateway-sdk-version"] = "ios:v\(SessionManager.sdkVersion),\(SessionManager.sdkType):v\(SessionManager.hybridSdkVersion!)"
        } else {
            headerStruct["x-gateway-sdk-version"] = "ios:v\(SessionManager.sdkVersion)"
        }
        
        print("HEADERS: \(headerStruct)")
        
        return headerStruct
    }
    
    //MARK: Query/Body Parameters
    var parameterEncoding: ParametersEncoding {
        switch self {
            default:
            return .body
        }
    }
    
    
}
