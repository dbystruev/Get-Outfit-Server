//
//  setup.swift
//
//  Created by Denis Bystruev on 15/09/2019.
//

import Kitura
import KituraStencil
import LoggerAPI
import SwiftRedis

func setup(_ catalog: YMLCatalog) {
    let xmlManager = XMLManager()
    xmlManager.parse { parsedCatalog, error in
        if let error = error {
            Log.error(error.localizedDescription)
            return
        }
        
        guard let parsedCatalog = parsedCatalog else {
            Log.error("Didn't get parsed catalogue")
            return
        }
        
        catalog.date = parsedCatalog.date
        catalog.shop = parsedCatalog.shop
    }
}

func setup(_ redis: Redis) {
    let host = "localhost"
    let port = Int32(6379)
    
    redis.connect(host: host, port: port) { error in
        if let error = error {
            Log.error("\(error.localizedDescription) at \(host):\(port)")
            return
        }
        
        #if DEBUG
        Log.info("Connected to Redis at \(host):\(port)")
        #endif
    }
}

func setup(_ router: Router) {
    router.setDefault(templateEngine: StencilTemplateEngine())

    router.get("/") { request, response, next in
       try response.render("home", context: [:])
       next()
    }

    router.get("stylist") { request, response, next in
        guard let subid = request.queryParameters["subid"] else {
            try response.status(.badRequest).end()
            return
        }

        Log.info("Generated links for subid: \(subid)")

        try response.render("stylist", context: ["subid": subid])
        
        next()
    }
}
