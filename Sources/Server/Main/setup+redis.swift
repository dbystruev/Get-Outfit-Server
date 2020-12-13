//
//  setup+redis.swift
//
//  Created by Denis Bystruev on 15/09/2019.
//

import Kitura
import LoggerAPI

// MARK: - Setup Redis
func setupRedis() {
    RedisManager.connect { error in
        if let error = error {
            Log.error("\(error.localizedDescription) at \(RedisManager.host):\(RedisManager.port)")
            return
        }
        
        #if DEBUG
        Log.debug("Connected to Redis at \(RedisManager.host):\(RedisManager.port)")
        #endif
    }
}
