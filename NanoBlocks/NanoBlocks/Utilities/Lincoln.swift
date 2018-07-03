//
//  Lincoln.swift
//  RaiBlocksWallet
//
//  Created by Ben Kray on 12/24/17.
//  Copyright © 2017 Planar Form. All rights reserved.
//

import Foundation

/// A shitty logger.

struct Lincoln {
    
    static private(set) var consoleLog: [String] = []
    
    static func log(_ message: String = "", inConsole: Bool = false, file: String = #file, line: Int = #line, function: String = #function) {
        #if DEBUG
            if let file = NSURL(fileURLWithPath: file).lastPathComponent {
                let funct = function + (function.contains("()") ? "" : "()")
                var output = "\(file), line \(line) -- \(funct)"
                output += message != "" ? " --\n\(message)" : ""
                NSLog(output)
            }
        #endif
        
        if inConsole {
            let datedMessage = "[\(Date().description)]\n"
            consoleLog.append(datedMessage + message)
        }
    }
    
    static func clearLog() {
        consoleLog = []
    }
}
