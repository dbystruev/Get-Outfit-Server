//
//  setup+redis.swift
//
//  Created by Denis Bystruev on 15/09/2019.
//

import Kitura
import LoggerAPI
import SwiftRedis

// MARK: - Setup Redis
func setup(_ redis: Redis) {
    let host = "localhost"
    let port = Int32(6379)
    
    redis.connect(host: host, port: port) { error in
        if let error = error {
            Log.error("\(error.localizedDescription) at \(host):\(port)")
            return
        }
        
        #if DEBUG
        Log.debug("Connected to Redis at \(host):\(port)")
        #endif
    }
}
