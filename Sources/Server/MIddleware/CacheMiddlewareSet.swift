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
        let key = request.queryParametersMultiValues.debugDescription
        cache.setObject(response, forKey: key)
        #if DEBUG
        Log.debug("Object for \(key) is set")
        #endif
        next()
    }
}
