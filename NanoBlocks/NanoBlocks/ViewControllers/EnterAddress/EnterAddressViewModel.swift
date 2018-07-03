//
//  EnterAddressViewModel.swift
// NanoBlocks
//
//  Created by Ben Kray on 3/26/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import Foundation

struct EnterAddressViewModel {
    
    private(set) var entries: [AddressEntry] = []
    private(set) var filteredEntries: [AddressEntry] = []
    private(set) var addressMap: [String: String] = [:]
    
    var count: Int {
        return filteredEntries.count
    }
    
    init() {
        self.entries = PersistentStore.getAddressEntries()
        self.filteredEntries = Array(entries)
        self.entries.forEach { self.addressMap[$0.address] = $0.name }
    }
    
    subscript(_ index: Int) -> AddressEntry? {
        guard index < filteredEntries.count else { return nil }
        return filteredEntries[index]
    }
    
    mutating func filter(with text: String) {
        let t = text.lowercased()
        filteredEntries = entries.filter { $0.name.lowercased().contains(t) || $0.address.lowercased().contains(t) }
    }
    
    mutating func resetFilter() {
        filteredEntries = Array(entries)
    }
}
