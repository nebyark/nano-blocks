//
//  CanoeService.swift
// NanoBlocks
//
//  Created by Ben Kray on 3/20/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import Foundation
import Moya

protocol BlockAdapter {
    var json: [String: String] { get }
}

enum CanoeService {
    case serverStatus
    case process(block: BlockAdapter)
    case generateWork(hash: String)
    case accountHistory(address: String, count: Int)
    case ledger(address: String, count: Int)
    case blockInfo(hashes: [String])
    case pending(accounts: [String], count: Int)
    case createServerAccount(walletID: String, username: String, password: String)
}

extension CanoeService: TargetType {
    var baseURL: URL {
        return URL(string: "https://getcanoe.io")!
    }
    
    var path: String {
        return "rpc"
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .serverStatus:
            return params(for: "canoe_server_status")
        case .accountHistory(let address, let count):
            return params(for: "account_history", params: ["account": address, "count": count])
        case .blockInfo(let hashes):
            return params(for: "blocks_info", params: ["hashes": hashes, "source": true])
        case .generateWork(let hash):
            return params(for: "work_generate", params: ["hash": hash])
        case .ledger(let address, let count):
            return params(for: "ledger", params: ["account": address, "count": count, "representative": true, "pending": true])
        case .process(let block):
            guard let jsonData = try? JSONSerialization.data(withJSONObject: block.json, options: []),
                let blockString = String(data: jsonData, encoding: .ascii) else { return .requestPlain }
            return params(for: "process", params: ["block": blockString])
        case .pending(let accounts, let count):
            return params(for: "accounts_pending", params: ["accounts": accounts, "count": count])
        case .createServerAccount(let walletID, let username, let password):
            return params(for: "create_server_account", params: ["wallet": walletID, "token": username, "tokenPass": password])
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    fileprivate func params(for action: String, params: [String: Any] = [:]) -> Task {
        var p: [String: Any] = ["action": action]
        p.merge(params) { (current, _) in current }
        return .requestParameters(parameters: p, encoding: JSONEncoding.default)
    }
}
