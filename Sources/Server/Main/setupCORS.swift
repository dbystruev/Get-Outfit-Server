//
//  setupCORS.swift
//
//  Created by Denis Bystruev on 04/03/2020.
//

import Kitura
import KituraCORS

// MARK: - Setup Router
func setupCORS(_ router: Router) {
    let options = Options()
    let cors = CORS(options: options)

    router.all("/", middleware: cors)
}