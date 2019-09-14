//
//  YMLShop.swift
//
//  Created by Denis Bystruev on 13/09/2019.
//
// Subset of https://yandex.ru/support/partnermarket/elements/shop.html
// <name> replaced with <title>

import Foundation

struct YMLShop: Codable {
    let title: String
    let company: String
    let url: URL
    let categories: [YMLCategory]
    let currencies: [YMLCurrency]
    let offers: [YMLOffer]
}
