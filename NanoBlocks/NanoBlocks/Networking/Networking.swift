//
//  Networking.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 1/16/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import Alamofire

class Networking {
    
    let sessionManager: SessionManager = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        return SessionManager(configuration: config)
    }()
    static let shared: Networking = Networking()
    typealias CompletionHandler = (DataResponse<Any>) -> Void
    
    func post(url: URLConvertible, params: Parameters, handler: CompletionHandler? = nil) {
        sessionManager.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { (response) in
            handler?(response)
        }
    }
    
    func get(url: URLConvertible, handler: CompletionHandler? = nil) {
        sessionManager.request(url, method: .get, encoding: JSONEncoding.default).responseJSON { (response) in
            handler?(response)
        }
    }
}
