//
//  NetworkAdapter.swift
// NanoBlocks
//
//  Created by Ben Kray on 3/20/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import Foundation
import Moya
import Result

public struct NetworkAdapter {
    
    enum APIError: Error {
        case fork
        case oldBlock
        case badResponse
        // May actually be known, just didnt account for it here yet
        case unknown(message: String)
        
        static func parseError(_ msg: String?) -> APIError? {
            guard let msg = msg else { return nil }
            switch msg {
            case "Fork":
                return .fork
            case "Old block":
                return .oldBlock
            default:
                return .unknown(message: msg)
            }
        }
        
        var message: String {
            switch self {
            case .fork: return "Fork detected"
            case .oldBlock: return "Old block detected"
            case .badResponse: return "Bad response"
            case .unknown(message: let msg): return msg
            }
        }
        // TODO: get other error messages
    }
    
    static let provider = MoyaProvider<CanoeService>()
    static let ninjaProvider = MoyaProvider<NanoNodeNinjaService>()
    
    // MARK: - Canoe
    
    static func blockInfo(hashes: [String], completion: @escaping ([BlockInfo], APIError?) -> Void) {
        request(target: .blockInfo(hashes: hashes), success:  { (response) in
            guard let json = try? response.mapJSON() as? [String: Any],
                let blocks = json?["blocks"] as? [String: [String: Any]] else {
                completion([], APIError.badResponse)
                return
            }
            completion(hashes.map { BlockInfo(blocks[$0]) }, nil)
        })
    }
    
    static func process(block: BlockAdapter, completion: ((String?, APIError?) -> Void)? = nil) {
        Lincoln.log("Broadcasting block '\(block.json)'", inConsole: true)
        request(target: .process(block: block), success: { (response) in
            guard let json = try? response.mapJSON() as? [String: String] else {
                completion?(nil, APIError.badResponse)
                return
            }
            Lincoln.log("Process Response: \(json ?? [:])", inConsole: true)
            let hash = json?["hash"]
            let error = APIError.parseError(json?["error"])
            completion?(hash, error)
        })
    }
    
    static func createAccountForSub(_ walletID: String, username: String, password: String, completion: @escaping (String?) -> Void) {
        request(target: .createServerAccount(walletID: walletID, username: username, password: password), success: { (response) in
            guard let json = try? response.mapJSON() as? [String: String] else { completion(nil); return }
            completion(json?["status"])
        })
    }
    
    static func getLedger(account: String, count: Int = 1, completion: @escaping (AccountInfo?) -> Void) {
        request(target: .ledger(address: account, count: 1), success: { (response) in
            // Funky response here, if the account doesn't exist yet, a random (perhaps adjacent in DB?) account is returned. Ensure that the requesting account is equal to the account in the response
            guard let json = try? response.mapJSON() as? [String: Any] else { completion(nil); return }
            let info = AccountInfo.fromJSON(json, account: account)
            completion(info)
        })
    }
    
    static func getAccountHistory(account: String, count: Int, completion: @escaping ([SimpleBlock]) -> Void) {
        request(target: .accountHistory(address: account, count: count), success: { (response) in
            if let json = try? response.mapJSON() as? [String: Any],
                let blocks = json?["history"] as? [[String: String]] {
                let accountHistory = blocks.map { SimpleBlock.fromJSON($0) }
                completion(accountHistory)
            }
        })
    }
    
    static func getWork(hash: String, completion: @escaping (String?) -> Void) {
        Lincoln.log("Fetching work on '\(hash)'", inConsole: true)
        request(target: .generateWork(hash: hash), success: { (response) in
            let json = try? response.mapJSON() as? [String: String]
            completion(json??["work"])
        })
    }
    
    static func getPending(for account: String, count: Int = 4096, completion: @escaping ([String]) -> Void) {
        request(target: .pending(accounts: [account], count: count), success: { (response) in
            do {
                let json = try response.mapJSON() as? [String: Any]
                guard let blocks = json?["blocks"] as? [String: Any],
                    let pending = blocks[account] as? [String] else { completion([]); return }
                Lincoln.log("Pending blocks \(pending)", inConsole: true)
                completion(pending)
            } catch {
                completion([])
            }
        })
    }
    
    // MARK: - Nano Node Ninja
    
    static func getVerifiedReps(completion: @escaping ([VerifiedAccount]) -> Void) {
        request(target: .verified, success: { (response) in
            do {
                let accounts = try JSONDecoder().decode([VerifiedAccount].self, from: response.data)
                completion(accounts)
            } catch {
                completion([])
            }
        })
    }
    // MARK: - Helper
    
    static func request(target: NanoNodeNinjaService, success successCallback: @escaping (Response) -> Void, error errorCallback: ((Swift.Error) -> Void)? = nil, failure failureCallback: ((MoyaError) -> Void)? = nil) {
        ninjaProvider.request(target) { (result) in
            handleResult(result, success: successCallback, error: errorCallback, failure: failureCallback)
        }
    }
    
    static func request(target: CanoeService, success successCallback: @escaping (Response) -> Void, error errorCallback: ((Swift.Error) -> Void)? = nil, failure failureCallback: ((MoyaError) -> Void)? = nil) {
        provider.request(target) { (result) in
            handleResult(result, success: successCallback, error: errorCallback, failure: failureCallback)
        }
    }
    
    fileprivate static func handleResult(_ result: Result<Response, MoyaError>, success successCallback: @escaping (Response) -> Void, error errorCallback: ((Swift.Error) -> Void)? = nil, failure failureCallback: ((MoyaError) -> Void)? = nil) {
        switch result {
        case .success(let response):
            #if DEBUG
                if let url = response.request?.url?.absoluteString, let json = try? response.mapJSON() {
                    var status = "\nSTATUS CODE: \(response.statusCode)\nURL: \(url)"
                    if let requestData = response.request?.httpBody, let requestBody = String(data: requestData, encoding: .utf8) {
                        status += "\nREQUEST BODY: \(requestBody)"
                    }
                    status += "\nRESPONSE BODY: \(json)"
                    Lincoln.log(status)
                }
            #endif
            if response.statusCode >= 200 && response.statusCode <= 300 {
                successCallback(response)
            } else {
                let error = NSError(domain: "com.planarform.nanoblocks", code: 420, userInfo: [NSLocalizedDescriptionKey: "Network Error"])
                errorCallback?(error)
            }
        case .failure(let error):
            failureCallback?(error)
        }
    }
}
