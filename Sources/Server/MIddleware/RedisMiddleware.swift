//
//  RedisMiddleware.swift
//  
//
//  Created by Denis Bystruev on 13.12.2020.
//

import Kitura
import LoggerAPI
import SwiftRedis

class RedisMiddleware: RouterMiddleware {
    // MARK: - Properties
    let callback: (_ request: RouterRequest, _ response: RouterResponse, _ next: @escaping () -> Void) throws -> ()
    let host: String
    let port: Int32
    
    // MARK: - Init
    init(host: String, port: Int32, get: Bool) {
        self.host = host
        self.port = port
        callback = get ? RedisMiddleware.handleGet : RedisMiddleware.handleSet
    }
    
    // MARK: - Static Methods
    /// Create string key based on router request query parameters
    /// - Parameter request: router request
    /// - Returns: string representing a key
    static func getKey(for request: RouterRequest) -> String {
        // Copy request parameters
        var parameters = request.queryParametersMultiValues
        
        // Sort dictionary values
        for (key, value) in parameters { parameters[key] = value.sorted() }
        
        // Get array sorted by key
        let key = parameters.sorted(by: { $0.key <  $1.key }).description
        
        return key
    }
    
    static func handleGet(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        let key = getKey(for: request)
        RedisManager.redis.get(key) { value, error in
            guard let value = value else {
                if let error = error {
                    Log.error("Can't connect to redis: \(error)")
                    next()
                    return
                }
                #if DEBUG
                Log.debug("Value for \(key) is NOT found in cache")
                #endif
                next()
                return
            }
            
            #if DEBUG
            Log.debug("Value for \(key) is found in cache: \(value)")
            #endif
            next()
        }
    }
    
    static func handleSet(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        let key = getKey(for: request)
        let value = response.userInfo.description
        RedisManager.redis.set(key, value: value) { success, error in
            guard success else {
                let message = error?.localizedDescription ?? "host \(RedisManager.host), port \(RedisManager.port)"
                Log.error("Can't connect to redis: \(message)")
                next()
                return
            }
            #if DEBUG
            Log.debug("Value \(value) for \(key) is set")
            #endif
            next()
        }
    }
    
    // MARK: - RouterMiddleware
    /// Check that request is present in cache and return it if it has
    public func handle(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        try self.callback(request, response, next)
    }
}
