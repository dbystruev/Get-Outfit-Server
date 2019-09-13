//
//  XMLManager.swift
//
//  Created by Denis Bystruev on 13/09/2019.
//

import Foundation

class XMLManager {
    // MARK: Errors
    enum LoadErrors: Error {
        case invalidLocalURL
        case invalidRemoteURL
        case noRemoteData
    }
    
    // MARK: Stored Properties
    var remotePath = "http://export.admitad.com/ru/webmaster/websites/838792/products/export_adv_products/"
    
    var remoteParameters = [
        "currency": "RUB",
        "code": "0khxm6hgw5",
        "feed_id": "15540",
        "last_import": "2000.01.01.00.00",
        "template": "45655",
        "user": "Kimsanzhiev",
    ]
    
    let localPath = "XML/full.xml"
    let localIncrementalUpdatePath = "XML/update.xml"
    
    // MARK: Computed Properties
    var isLoaded: Bool {
        guard let fullPath = localURL?.path else { return false }
        var isDirectory = ObjCBool(true)
        let fileExists = FileManager.default.fileExists(atPath: fullPath, isDirectory: &isDirectory)
        let isReadable = FileManager.default.isReadableFile(atPath: fullPath)
        return fileExists && isReadable && !isDirectory.boolValue
    }
    
    var localURL: URL? {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls.first?.appendingPathComponent(localPath)
    }
    
    // MARK: Methods
    func saveRemote(completion: @escaping (Error?) -> Void) {
        guard let localURL = localURL else {
            completion(LoadErrors.invalidLocalURL)
            return
        }
        
        guard let url = URL(string: remotePath)?.withQueries(remoteParameters) else {
            completion(LoadErrors.invalidRemoteURL)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil else {
                completion(error)
                return
            }
            
            guard let data = data else {
                completion(LoadErrors.noRemoteData)
                return
            }
            
            do {
                try data.write(to: localURL, options: .atomicWrite)
                completion(nil)
            } catch let writeError {
                completion(writeError)
            }
        }
        task.resume()
    }
}
