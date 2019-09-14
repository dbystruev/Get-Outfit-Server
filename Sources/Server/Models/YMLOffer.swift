//
//  YMLOffer.swift
//
//  Created by Denis Bystruev on 13/09/2019.
//
// Subset of https://yandex.ru/support/partnermarket/export/vendor-model.html

import Foundation

struct YMLOffer: Codable {
    let available: Bool?
    let deleted: Bool?
    let id: String
    let categoryId: Int?
    let currencyId: String?
    let description: String?
    let manufacturer_warranty: Bool?
    let model: String?
    let modified_time: Date?
    let name: String?
    let params: [String: String]?
    let pictures: [URL]?
    let price: Decimal?
    let sales_notes: String?
    let typePrefix: String?
    let url: URL?
    let vendor: String?
    let vendorCode: String?
}
