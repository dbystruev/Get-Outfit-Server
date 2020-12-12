//
//  CacheMiddlewareGet.swift
//  CHTTPParser
//
//  Created by Denis Bystruev on 12.12.2020.
//

import Kitura
import KituraCache
import LoggerAPI

class CacheMiddlewareGet: RouterMiddleware {
    /// Check that request is present in cache and return it if it has
    public func handle(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        if let _ = cache.object(forKey: request.parameters) as? RouterResponse {
            #if DEBUG
            Log.debug("Object for \(request.parameters) is found in cache")
            #endif
        } else {
            #if DEBUG
            Log.debug("Object for \(request.parameters) is NOT found in cache")
            #endif
        }
        next()
    }
}
