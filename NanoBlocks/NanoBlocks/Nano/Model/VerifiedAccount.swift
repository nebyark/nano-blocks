//
//  VerifiedAccount
// NanoBlocks
//
//  Created by Ben Kray on 4/25/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import Foundation

struct VerifiedAccount: Codable {
    let account: String
    let alias: String
    let uptime: Float
    let delegators: Int
    let votingweight: Float
}
