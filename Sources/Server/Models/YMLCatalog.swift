//
//  YMLCatalog.swift
//
//  Created by Denis Bystruev on 13/09/2019.
//
//  See https://yandex.ru/support/partnermarket/export/yml.html

import Foundation

struct YMLCatalog: Codable {
    let date: Date
    let shop: YMLShop
}
