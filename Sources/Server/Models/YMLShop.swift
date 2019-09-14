//
//  YMLShop.swift
//
//  Created by Denis Bystruev on 13/09/2019.
//
// Subset of https://yandex.ru/support/partnermarket/elements/shop.html
// <name> replaced with <title>

import Foundation

struct YMLShop: Codable {
    var title: String?
    var company: String?
    var url: URL?
    var categories = [YMLCategory]()
    var currencies = [YMLCurrency]()
    var offers = [YMLOffer]()
}

// MARK: - XMLElement
extension YMLShop: XMLElement {
    var elementName: String {
        return "shop"
    }
    
    mutating func addChild(_ child: XMLElement) {
        switch child.elementName {
        case "title":
            title = child.characters
        case "company":
            company = child.characters
        case "url":
            url = URL(string: child.characters)
        case "categories":
            for child in child.children {
                if let category = child as? YMLCategory {
                    categories.append(category)
                }
            }
        case "currencies":
            for child in child.children {
                if let currency = child as? YMLCurrency {
                    currencies.append(currency)
                }
            }
        case "offers":
            for child in child.children {
                if let offer = child as? YMLOffer {
                    offers.append(offer)
                }
            }
        default:
            break
        }
    }
}
