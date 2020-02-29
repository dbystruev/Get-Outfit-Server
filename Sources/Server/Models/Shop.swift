//
//  Shop.swift
//
//  Created by Denis Bystruev on 29/02/2020.
//

import Foundation

struct Shop: Codable {
    let code: String
    let currency: String
    let feed_id: String
    let format: String
    let last_import: String
    let name: String
    let remotePath: String
    let template: String
    let user: String
}