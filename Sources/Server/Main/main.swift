//
//  main.swift
//
//  Created by Denis Bystruev on 10/09/2019.
//

import Foundation
import HeliumLogger
import Kitura
import LoggerAPI
import SwiftMetrics
import SwiftRedis

#if DEBUG
HeliumLogger.use(.debug)
#else
HeliumLogger.use(.info)
#endif

let catalog = YMLCatalog()
// let metrics = try SwiftMetrics()
let redis = Redis()
let router = Router()
let xmlManager = XMLManager()

setup { loadedCatalog, error in
    if let error = error {
        Log.error(error.localizedDescription)
    }
    
    if let loadedCatalog = loadedCatalog {
        catalog.date = loadedCatalog.date
        catalog.shop = loadedCatalog.shop
    } else {
        Log.error("Loading empty shop")
        catalog.date = Date(timeIntervalSince1970: 0)
        catalog.shop = YMLShop.emptyShop
    }
    
    // setup(metrics)
    setup(redis)
    setup(router)
}

Kitura.addHTTPServer(onPort: 8888, with: router)
Kitura.run()
