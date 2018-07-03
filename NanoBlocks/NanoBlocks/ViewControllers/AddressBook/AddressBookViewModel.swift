//
//  AddressBookViewModel.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 1/23/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import Foundation

class AddressBookViewModel {
    
    private(set) var filteredEntries: [AddressEntry] = []
    private(set) var entries: [AddressEntry] = []
    init() {
        updateData()
    }
    
    subscript(index: Int) -> AddressEntry? {
        guard index < filteredEntries.count else { return nil }
        return filteredEntries[index]
    }
    
    func updateData() {
        self.entries = PersistentStore.getAddressEntries()
        self.filteredEntries = Array(entries)
    }
    
    func removeEntry(at index: Int) {
        guard index < entries.count else { return }
        let entry: AddressEntry = entries.remove(at: index)
        PersistentStore.removeAddressEntry(entry)
        updateData()
    }
    
    func saveEntry(name: String?, address: String?) {
        guard let name = name, let address = address else { return }
        PersistentStore.addAddressEntry(name, address: address)
        updateData()
    }
    
    func filter(with text: String) {
        let t = text.lowercased()
        filteredEntries = entries.filter { $0.name.lowercased().contains(t) || $0.address.lowercased().contains(t) }
    }
    
    func resetFilter() {
        filteredEntries = Array(entries)
    }
}
