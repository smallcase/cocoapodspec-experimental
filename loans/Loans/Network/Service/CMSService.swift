//
//  CMSService.swift
//  Loans
//
//  Created by Ankit Deshmukh on 30/05/23.
//

import Foundation

enum CMSService: ServiceProtocol {
    
    case getLenderConfig
    case getGatewayIosConfig
    
    //MARK: Base URL
    private var baseUrlString: String {
        
        switch SessionManager.baseEnvironment {
        case .production:
            return "https://cms.smallcase.com/"
        case .staging:
            return "https://cms.stag.smallcase.com/"
        case .development:
            return "https://cms-dev.smallcase.com/"
        }
    }
    
    var baseURL: URL {
        return URL(string: baseUrlString)!
    }
    
    //MARK: Path
    var path: String? {
        switch self {
            case .getLenderConfig:
                return "lender-configs"
        case .getGatewayIosConfig:
            return "gateway-ios-config"
        }
    }
    
    var method: HTTPMethod {
        switch self {
            default:
                return .get
        }
    }
    
    //MARK: Parameters
    private var parameters: Parameters? {
        return nil
    }
    
    var task: Task {
        if let params = parameters { return .requestParameters(params) }
        return .requestPlain
    }
    
    var headers: Headers? {
        return nil
    }
    
    var parameterEncoding: ParametersEncoding {
        return .query
    }
    
    
}
