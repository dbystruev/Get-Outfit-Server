//
//  File.swift
//  
//
//  Created by Denis Bystruev on 13.12.2020.
//

import Foundation
import Kitura
import LoggerAPI
import SwiftRedis

class RedisManager {
    // MARK: - Static Properties
    static let host = "redis" // "localhost"
    static let middleware = RedisMiddleware(host: host, port: port)
    static let port = Int32(6379)
    static let redis = Redis()
    
    // MARK: - Static Methods
    static func connect(callback: (NSError?) -> Void) {
        redis.connect(host: host, port: port, callback: callback)
    }
    
    /// Delete all the keys of the currently selected database
    static func flushdb() {
        redis.flushdb { success, error in
            guard success else {
                let message = error?.localizedDescription ?? "unknown error"
                Log.error("Can't flush redis database: \(message)")
                return
            }
            
            #if DEBUG
            Log.debug("Successfully flushed redis database")
            #endif
        }
    }
    
    static func set(request: RouterRequest, value: String) {
        RedisMiddleware.set(request: request, value: value)
    }
}
