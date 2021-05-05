//
//  RemoteShop.swift
//
//  Created by Denis Bystruev on 29/02/2020.
//

import Foundation

struct RemoteShop: Codable {
    let code: String?
    let currency: String?
    let feed_id: String?
    let format: String?
    let last_import: String?
    let name: String
    let path: String
    let template: String?
    let user: String?
    
    init(
        code: String? = nil,
        currency: String? = nil,
        feed_id: String? = nil,
        format: String? = nil,
        last_import: String? = nil,
        name: String,
        path: String,
        template: String? = nil,
        user: String? = nil
    ) {
        self.code = code
        self.currency = currency
        self.feed_id = feed_id
        self.format = format
        self.last_import = last_import
        self.name = name
        self.path = path
        self.template = template
        self.user = user
    }
}
