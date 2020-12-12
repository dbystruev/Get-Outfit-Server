//
//  CacheMiddlewareSet.swift
//  Server
//
//  Created by Denis Bystruev on 12.12.2020.
//

import Kitura
import KituraCache
import LoggerAPI

class CacheMiddlewareSet: RouterMiddleware {
    /// Check that request is present in cache and return it if it has
    public func handle(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        cache.setObject(response, forKey: request.parameters)
        #if DEBUG
        Log.debug("Object for \(request.parameters) is set")
        #endif
        next()
    }
}
