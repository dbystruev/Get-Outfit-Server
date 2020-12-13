//
//  File.swift
//  
//
//  Created by Denis Bystruev on 13.12.2020.
//

import Foundation
import SwiftRedis

class RedisManager {
    // MARK: - Static Properties
    static let get = RedisMiddleware(host: host, port: port, get: true)
    static let host = "redis" // "localhost"
    static let port = Int32(6379)
    static let redis = Redis()
    static let set = RedisMiddleware(host: host, port: port, get: false)
    
    // MARK: - Static Methods
    static func connect(callback: (NSError?) -> Void) {
        redis.connect(host: host, port: port, callback: callback)
    }
}
