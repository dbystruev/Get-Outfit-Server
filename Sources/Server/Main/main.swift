//
//  main.swift
//
//  Created by Denis Bystruev on 10/09/2019.
//

import HeliumLogger
import Kitura
import LoggerAPI
import SwiftRedis

#if DEBUG
HeliumLogger.use(.debug)
#else
HeliumLogger.use(.info)
#endif

let catalog = YMLCatalog()
setup(catalog)

let redis = Redis()
setup(redis)

let router = Router()
setup(router)

Kitura.addHTTPServer(onPort: 8080, with: router)
Kitura.run()
