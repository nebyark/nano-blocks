//
//  BlockInfoViewModel.swift
// NanoBlocks
//
//  Created by Ben Kray on 4/23/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import Foundation

class BlockInfoViewModel {
    let info: SimpleBlockBridge
    private(set) var model: BlockInfo?
    var localizedDate: String? {
        guard let epoch = model?.timestamp else { return nil }
        let date = Date(timeIntervalSince1970: TimeInterval(Float(epoch) / 1000.0))
        return DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short)
    }
    init(with info: SimpleBlockBridge) {
        self.info = info
    }
    
    func fetch(_ completion: @escaping () -> Void) {
        NetworkAdapter.blockInfo(hashes: [info.blockHash]) { [weak self] (info, error) in
            guard error == nil else {
                Banner.show(error?.localizedDescription ?? "Fetch error", style: .danger)
                completion()
                return
            }
            self?.model = info.first
            completion()
        }
    }
}
