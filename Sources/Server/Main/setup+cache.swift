//
//  setup+cache.swift
//  
//
//  Created by Denis Bystruev on 12.12.2020.
//

import Kitura
import KituraCache
import LoggerAPI

// MARK: - Setup Cache
func setup(_ cache: KituraCache, for router: Router) {
    // Reset the cache and its statistics
    cache.flush()
    
    #if DEBUG
    Log.debug("Cache \(cache) has been setup")
    #endif
}
