//
//  BlockHandler.swift
//  NanoBlocks
//
//  Created by Ben Kray on 5/10/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import Foundation

struct BlockHandler {
    enum BlockHandlerError: Error {
        case proofOfWork
        case process(String?)
        case unknown
        case apiError(NetworkAdapter.APIError)
        case alreadyInProgress
        
        var description: String {
            switch self {
            case .proofOfWork: return "Proof of Work"
            case .process(let msg):
                if let msg = msg {
                    return "Process (\(msg))"
                } else {
                    return "Something happened when processing the block"
                }
            case .apiError(let error): return error.message
            case .unknown: return "Unknown"
            case .alreadyInProgress: return "Broadcast already in progress"
            }
        }
    }
    enum Result {
        case success(String)
        case failure(BlockHandlerError)
    }
    
    fileprivate static var processing: Set<String> = []
    
    static func handle(_ block: StateBlock, for account: String, completion: @escaping (BlockHandler.Result) -> Void) {
        var block = block
        guard let accountPublic = WalletUtil.derivePublic(from: account) else {
            completion(.failure(.unknown))
            return
        }
        let workInput = block.intent == .open ? accountPublic : block.previous
        guard !processing.contains(workInput) else {
            completion(.failure(.alreadyInProgress))
            return
        }
        processing.insert(workInput)
        NetworkAdapter.getWork(hash: workInput) { (work) in
            guard let work = work else {
                processing.remove(workInput)
                completion(.failure(.proofOfWork))
                return
            }
            block.work = work
            NetworkAdapter.process(block: block) { (blockHash, error) in
                defer {
                    processing.remove(workInput)
                }
                if let error = error {
                    completion(.failure(.apiError(error)))
                } else if let blockHash = blockHash {
                    completion(.success(blockHash))
                } else {
                    completion(.failure(.unknown))
                }
            }
        }
    }
}
