//
//  NanoNodeNinjaService.swift
// NanoBlocks
//
//  Created by Ben Kray on 4/25/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import Foundation
import Moya

enum NanoNodeNinjaService {
    case active
    case verified
}

extension NanoNodeNinjaService: TargetType {
    var baseURL: URL {
        return URL(string: "https://nanonode.ninja")!
    }
    var path: String {
        switch self {
        case .active:
            return "api/accounts/active"
        case .verified:
            return "api/accounts/verified"
        }
    }
    var method: Moya.Method {
        return .get
    }
    var sampleData: Data {
        return Data()
    }
    var task: Task {
        return .requestPlain
    }
    var headers: [String : String]? {
        return nil
    }
}
