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
if xmlManager.isLoaded {
    if let xmlPath = xmlManager.localURL?.path {
        Log.info("XML data is already loaded to \(xmlPath)")
    } else {
        Log.info("XML data is already loaded")
    }
} else {
    xmlManager.saveRemote { error in
        if let xmlURL = xmlManager.localURL, error == nil {
            Log.info("Loaded XML data to \(xmlURL.path)")
        } else {
            if let error = error {
                Log.error(error.localizedDescription)
            } else {
                Log.error("Can't load XML data")
            }
        }
    }
}

let router = Router()
setupRoutes(for: router)

Kitura.addHTTPServer(onPort: 8080, with: router)
Kitura.run()
