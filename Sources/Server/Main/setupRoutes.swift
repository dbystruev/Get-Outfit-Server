//
//  setupRoutes.swift
//
//  Created by Denis Bystruev on 13/09/2019.
//

import Kitura
import KituraStencil
import LoggerAPI

func setupRoutes(for router: Router) {
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
