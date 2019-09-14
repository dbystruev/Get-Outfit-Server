//
//  main.swift
//
//  Created by Denis Bystruev on 10/09/2019.
//

import HeliumLogger
import Kitura
import LoggerAPI

HeliumLogger.use(.info)

let xmlManager = XMLManager()
xmlManager.parse { catalog, error in
    if let error = error {
        Log.error(error.localizedDescription)
    } else {
        Log.info("Finished parsing")
    }
}

let router = Router()
setupRoutes(for: router)

Kitura.addHTTPServer(onPort: 8080, with: router)
Kitura.run()
