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
    private static let redis = Redis()
    
    // MARK: - Static Methods
    static func connect(callback: (NSError?) -> Void) {
        redis.connect(host: host, port: port, callback: callback)
    }
    
    /// Get the value of a key
    /// - Parameters:
    ///   - key: the key
    ///   - callback: the callback function with the value of the key. NSError will be non-nil if an error occurred.
    static func get(_ key: String, callback: (RedisString?, NSError?) -> Void) {
        redis.get(key, callback: callback)
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
    
    /// Set a key to hold a value. If key already holds a value, it is overwritten.
    /// - Parameters:
    ///   - key: the key
    ///   - value: the String value to set
    ///   - callback: The callback function after setting the value. Bool will be true if the key was set. NSError will be non-nil if an error occurred.
    static func set(_ key: String, value: String, callback: (Bool, NSError?) -> Void) {
        redis.set(key, value: value, callback: callback)
    }
    
    static func set(request: RouterRequest, value: String) {
        RedisMiddleware.set(request: request, value: value)
    }
}
