//
//  SCGateway+API.swift
//  SCGateway
//
//  Created by Shivani on 14/11/19.
//  Copyright © 2019 smallcase. All rights reserved.
//

import Foundation

/// Smallcase Transaction Methods
 public extension SCGateway {

    @objc func getSmallcases(params: [String: Any]?, completion: @escaping(Data?, Error?) -> Void) {
    
    guard SessionManager.gatewayName != nil else {
        completion(nil, SCGatewayError.configNotSet)
        return
    }
    
    var sortParams: [String: Any] = [
        "sortBy" : "default",
        "sortOrder": 1
    ]
    if let params = params {
        sortParams.merge(params) { (_, next) in next }
    }
    
    sessionProvider.requestJson(service: GatewayService.getSmallcases(params: sortParams)) { (result) in
        switch result {
        case .success(let data):
            completion(data, nil)
        case .failure(let error):
            completion(nil, error)
        }
    }
}
    
    @objc func getSmallcaseProfile(scid: String, completion: @escaping(Data?, Error?) -> Void) {
    
    guard SessionManager.gatewayName != nil else { completion(nil, SCGatewayError.configNotSet)
        return
    }
    
    sessionProvider.requestJson(service: GatewayService.getSmallcaseProfile(scid: scid)) { (result) in
        switch result {
        case .success(let data):
            completion(data, nil)
        case .failure(let error):
            completion(nil, error)
        }
    }
}
    
    @objc func getSmallcaseNews(scid: String?, iscid: String?, optionalParams: [String: Any]?, completion: @escaping(Data?, Error?) -> Void) {
        
        guard SessionManager.gatewayName != nil else { completion(nil, SCGatewayError.configNotSet)
            return
        }
        
        if scid == nil && iscid == nil {
            completion(nil, NetworkError.invalidParams)
            return
        }
        var params: [String: Any] = [:]
        if let scid = scid {
            params["scid"] = scid
        }
        
        if let iscid = iscid {
            params["iscid"] = iscid
        }
        if let optionalParams = optionalParams {
            params = params.merging(optionalParams, uniquingKeysWith: { (_, new)  in new })
        }
        
        sessionProvider.requestJson(service: GatewayService.getNews(params: params)) { (result) in
            switch result {
            case let .success(data):
                completion(data, nil)
                
            case let .failure(error):
                completion(nil, error)
                
            }
        }
    }
    
    
       @objc func getUserInvestments(iscids: [String]?, completion: @escaping(Data?, Error?) -> Void) {
            guard SessionManager.gatewayName != nil else {
                completion(nil, SCGatewayError.configNotSet)
                return
            }
            guard SessionManager.broker != nil, let userStatus = SessionManager.userStatus, userStatus == .connected else {
                completion(nil, SCGatewayError.uninitialized)
                return
            }
    
            sessionProvider.requestJson(service: GatewayService.getUserInvestments(iscids: iscids) ) { (result) in
                switch result {
                case .success(let data):
                    completion(data, nil)
                    
                case .failure(let error):
                    completion(nil, error)
                }
            }
    
        }
    
      @objc func getExitedSmallcases(completion: @escaping(Data?, Error?) -> Void)  {
        
        guard SessionManager.broker != nil, let userStatus = SessionManager.userStatus, userStatus == .connected else {
            completion(nil, SCGatewayError.uninitialized)
            return
        }
        
        sessionProvider.requestJson(service: GatewayService.getExitedSmallcases ) { (result) in
            switch result {
            case .success(let data):
                completion(data,nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
        
        
    }
    
    @objc func markSmallcaseArchive(iscid: String, completion: @escaping(Data?, Error?) -> Void) {
        
        let params: [String: Any] = ["iscid":iscid]
        
        guard SessionManager.gatewayName != nil else {
            completion(nil, SCGatewayError.configNotSet)
            return
        }
        
        guard SessionManager.broker != nil, let userStatus = SessionManager.userStatus, userStatus == .connected else {
            completion(nil, SCGatewayError.uninitialized)
            return
        }
        
        sessionProvider.requestJson(service: GatewayService.markSmallcaseArchive(params: params)) { (result) in
            
            print("------> received result from API: \(result)")
            
            switch result {
                case .success(let data):
                    print("------> received success data: \(data.debugDescription)")
                    completion(data, nil)
                case .failure(let error):
                    print("------> received error data: \(error.localizedDescription)")
                    completion(nil, error)
            }
            
        }
        
    }
    

    @objc func getUserInvestmentDetails(iscid: String, completion: @escaping(Data?, Error?) -> Void ) {
        
        guard SessionManager.broker != nil, let userStatus = SessionManager.userStatus, userStatus == .connected else {
            completion(nil, SCGatewayError.uninitialized)
            return
        }
        
        sessionProvider.requestJson(service: GatewayService.getUserInvestmentDetails(iscid: iscid) ) { (result) in
            switch result {
            case .success(let data):
                completion(data, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
   @objc func getHistorical(scid: String, benchmarkId: String, base: Int = 100, duration: String?, completion:  @escaping(Data?, Error?) -> Void ) {

        var params: [String: Any] = [
            "scid" : scid,
            "benchmarkId": benchmarkId,
            "base": base,
            "benchmarkType": "index"
        ]
    
        if let duration = duration  {
            params["duration"] = duration
        }
        
        sessionProvider.requestJson(service: GatewayService.getHistorical(params: params) ) { (result) in
            switch result {
            case .success(let data):
                completion(data, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
}
