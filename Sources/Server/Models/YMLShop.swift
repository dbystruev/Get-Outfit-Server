//
//  YMLShop.swift
//
//  Created by Denis Bystruev on 13/09/2019.
//
// Subset of https://yandex.ru/support/partnermarket/elements/shop.html
// <name> replaced with <title>

import Foundation
import LoggerAPI

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
    var children: [XMLElement] {
        var children = [XMLElement]()
        
        if let title = title {
            children.append(GenericXMLElement(characters: title, elementName: "title"))
        }
        
        if let company = company {
            children.append(GenericXMLElement(characters: company, elementName: "company"))
        }
        
        if let url = url {
            children.append(GenericXMLElement(characters: url.absoluteString, elementName: "url"))
        }
        
        if !categories.isEmpty {
            children.append(GenericXMLElement(children: categories, elementName: "categories"))
        }
        
        if !currencies.isEmpty {
            children.append(GenericXMLElement(children: currencies, elementName: "currencies"))
        }
        
        if !offers.isEmpty {
            children.append(GenericXMLElement(children: offers, elementName: "offers"))
        }
        
        return children
    }
    
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
            for element in child.children {
                if let category = element as? YMLCategory {
                    categories.append(category)
                }
            }
        case "currencies":
            for element in child.children {
                if let currency = element as? YMLCurrency {
                    currencies.append(currency)
                }
            }
        case "offers":
            for element in child.children {
                if let offer = element as? YMLOffer {
                    offers.append(offer)
                }
            }
        default:
            break
        }
    }
}

// MARK: - Dummy Shop
extension YMLShop {
    static var dummyShop: YMLShop {
        return YMLShop(
            title: "Dummy Shop",
            company: "Dummy Company",
            url: URL(string: "http://dummyurl.com"),
            categories: [YMLCategory(id: 1, name: "Dummy Category", parentId: nil)],
            currencies: [YMLCurrency(id: "Dummy Currency", rate: "1")],
            offers: [YMLOffer(
                available: true,
                deleted: false,
                id: "Dummy ID",
                categoryId: 1,
                currencyId: "Dummy Currency",
                description: "Dummy Description",
                manufacturer_warranty: false,
                model: "Dummy Model",
                modified_time: Date(timeIntervalSince1970: 0),
                name: "Dummy Name",
                oldprice: nil,
                params: [],
                pictures: [],
                price: 100,
                sales_notes: "Dummy Notes",
                typePrefix: "Dummy Type",
                url: URL(string: "http://dummyurl.com"),
                vendor: "Dummy Vendor",
                vendorCode: "Dummy Vendor Code")
            ]
        )
    }
}

#if DEBUG
// MARK: - CustomStringConvertible
extension YMLShop: CustomStringConvertible {
    var description: String {
        var properties = ""
        if let title = title { properties += "title: \"\(title)\", " }
        if let company = company { properties += "company: \"\(company)\", " }
        if let url = url { properties += "url: \"\(url)\", " }
        if !categories.isEmpty { properties += "categories: \(categories.count) (last: \(categories.last!)), " }
        if !currencies.isEmpty { properties += "currencies: \(currencies), " }
        if !offers.isEmpty { properties += "offers: \(offers.count) (last: \(offers.last!), " }
        
        let name = "\(YMLShop.self)"
        if properties.isEmpty {
            return name
        } else {
            return "\(name)(\(properties.dropLast(2)))"
        }
    }
}
#endif
