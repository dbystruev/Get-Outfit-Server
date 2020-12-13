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
    let host: String
    let port: Int32
    
    // MARK: - Init
    init(host: String, port: Int32) {
        self.host = host
        self.port = port
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
    
    static func handle(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        let key = getKey(for: request)
        RedisManager.redis.get(key) { value, error in
            guard let value = value?.asString else {
                if let error = error {
                    Log.error("Redis error: \(error)")
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
            
            do {
                try response.send(value).end()
            } catch {
                next()
            }
        }
    }
    
    /// Set redis value for key defined by router request
    /// - Parameters:
    ///   - request: router request to define the key
    ///   - value: value to set
    static func set(request: RouterRequest, value: String) {
        let key = getKey(for: request)
        RedisManager.redis.set(key, value: value) { success, error in
            guard success else {
                let message = error?.localizedDescription ?? "host \(RedisManager.host), port \(RedisManager.port)"
                Log.error("Redis error: \(message)")
                return
            }
            
            #if DEBUG
            Log.debug("Value \(value) for \(key) is set")
            #endif
        }
    }
    
    // MARK: - RouterMiddleware
    func handle(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        try RedisMiddleware.handle(request: request, response: response, next: next)
    }
}
