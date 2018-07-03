//
//  RtChk.swift
// NanoBlocks
//
//  Created by Ben Kray on 3/6/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import UIKit

// Checks if a user is running the wallet app on a rooted device. If this is the case, the app should exit immediately so as to avoid runtime analysis from root tools like Cycript or Snoop-it.

struct RtChk {
    static func ir() -> Bool {
        
        var score: Int = 0
        
        // Open files we shouldn't be able to open/shouldn't exist
        let files = [
            "/Applications/Cydia.app",
            "/usr/sbin/sshd",
            "/bin/bash",
            "/usr/bin/ssh",
            "/etc/apt",
            "/Library/MobileSubstrate/MobileSubstrate.dylib"
        ]
        files.forEach {
            let file = fopen($0, "r")
            if file != nil {
                score += 1
                fclose(file)
            }
        }
        if score > 2 {
            return true
        }
        
        // Write outside of sandbox
        let t: NSString = "And blood-black nothingness began to spin... A system of cells interlinked within cells interlinked within cells interlinked within one stem... And dreadfully distinct against the dark, a tall white fountain played"
        do {
            try t.write(toFile: "/private/test.txt", atomically: true, encoding: String.Encoding.utf8.rawValue)
            try FileManager.default.removeItem(atPath: "/private/test.txt")
            // Should hit catch
            score += 1
        } catch { }
        
        return score > 3
    }
}
