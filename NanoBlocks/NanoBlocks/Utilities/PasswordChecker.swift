//
//  PasswordChecker.swift
// NanoBlocks
//
//  Created by Ben Kray on 3/24/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import Foundation

class PasswordChecker {
    
    lazy var words: [String] = {
        let path = Bundle.main.path(forResource: "weak_pw", ofType: "txt", inDirectory: nil, forLocalization: Locale.current.identifier)
        let items = NSArray(contentsOfFile: path ?? "") as? [String]
        return items ?? []
    }()
    
    /// Checks whether a given string is in the weak password list. Performs a binary search.
    ///
    /// - Parameter value: The value to check for.
    /// - Returns: Whether or not the value is in the list.
    func isPasswordWeak(_ value: String) -> Bool {
        var low: Int = 0
        var high: Int = words.count - 1
        
        while low <= high {
            let mid: Int = (low + high) / 2
            let compare = words[mid].compare(value)
            if compare == .orderedAscending {
                // current word is smaller than value, move low pointer to mid
                low = mid + 1
            } else if compare == .orderedDescending {
                high = mid - 1
            } else {
                return true
            }
        }
        return false
    }

}
