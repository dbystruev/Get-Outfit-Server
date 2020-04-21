//
//  setup+static.swift
//
//  Created by Denis Bystruev on 17/04/2020.
//

import Foundation
import Kitura
import KituraStencil
import LoggerAPI

// MARK: - Setup Router
func setupStatic(_ router: Router) {
    for folder in ["css", "fonts", "image", "js", "scss", "vendor"]{
        router.all("/\(folder)", middleware: StaticFileServer(path: "./Views/\(folder)"))
    }
}