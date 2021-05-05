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
let remoteShop = RemoteShop.all.last! // 0 – Lamoda, 1 — Farfetch, 2 — Acoola
let router = Router()
let xmlManager = XMLManager()

setupCatalog()
setupCORS(router)
setup(router)
setupRedis()
setupStatic(router)

Kitura.addHTTPServer(onPort: 8888, with: router)
Kitura.run()
