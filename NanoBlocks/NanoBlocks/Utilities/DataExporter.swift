//
//  DataExporter.swift
// NanoBlocks
//
//  Created by Ben Kray on 4/30/18.
//  Copyright © 2018 Planar Form. All rights reserved.
//

import Foundation
import SSZipArchive

class DataExporter {
    
    fileprivate let data: Data
    fileprivate let password: String?
    fileprivate let fileName: String = UUID().uuidString
    fileprivate var fileURL: URL?
    fileprivate var zipFileURL: URL?
    
    init(_ data: Data, password: String? = nil) {
        self.data = data
        self.password = password
    }
    
    // Clear out all files written to
    deinit {
        if let fileURL = fileURL {
            try? FileManager.default.removeItem(atPath: fileURL.path)
        }
        if let zipFileURL = zipFileURL {
            try? FileManager.default.removeItem(atPath: zipFileURL.path)
        }
    }
    
    /// Creates a zip file with the specified name.
    /// - Returns The path of the new file if one was created.
    func export(_ asHex: Bool = true) -> URL? {
        do {
            guard let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else { return nil }
            let writePath = NSURL(fileURLWithPath: cacheDir.absoluteString)
            guard let file = writePath.appendingPathComponent("\(self.fileName).txt") else { return nil }
            var dataString = ""
            if asHex {
                dataString = self.data.hexString
            } else {
                dataString = String(data: self.data, encoding: .utf8) ?? ""
            }
            try dataString.write(toFile: file.path, atomically: true, encoding: .utf8)
            self.fileURL = file
            let zipFile = cacheDir.appendingPathComponent("\(self.fileName).zip")
            SSZipArchive.createZipFile(atPath: zipFile.path, withFilesAtPaths: [file.path], withPassword: password)
            try FileManager.default.removeItem(atPath: file.path)
            self.zipFileURL = zipFile
        } catch {
            Lincoln.log(error.localizedDescription)
        }
        
        return zipFileURL
    }
}
