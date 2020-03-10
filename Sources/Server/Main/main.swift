//
//  main.swift
//
//  Created by Denis Bystruev on 10/09/2019.
//

import Foundation
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
let redis = Redis()
let remoteShop = RemoteShop.all[1] // 0 – Lamoda, 1 — Farfetch
let router = Router()
let xmlManager = XMLManager()

setupCatalog()

// setup(redis)
setupCORS(router)
setup(router)

Kitura.addHTTPServer(onPort: 8888, with: router)
Kitura.run()
