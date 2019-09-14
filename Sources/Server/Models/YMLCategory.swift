//
//  YMLCategory.swift
//
//  Created by Denis Bystruev on 13/09/2019.
//
//  See https://yandex.ru/support/partnermarket/elements/categories.html

struct YMLCategory: Codable {
    let id: Int
    let name: String
    let parentId: Int?
}
