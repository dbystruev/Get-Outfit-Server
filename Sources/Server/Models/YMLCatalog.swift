//
//  YMLCatalog.swift
//
//  Created by Denis Bystruev on 13/09/2019.
//
//  See https://yandex.ru/support/partnermarket/export/yml.html

import Foundation

struct YMLCatalog: Codable {
    var date: Date?
    var shop: YMLShop?
}

// MARK: - XMLElement
extension YMLCatalog: XMLElement {
    var attributes: [String : String] {
        get {
            guard let date = date else { return [:] }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateString = formatter.string(from: date)
            return ["date": dateString]
        }
        set {
            guard let dateString = newValue["date"] else { return }
            self.date = dateString.toDate
        }
    }
    
    var children: [XMLElement] {
        if let shop = shop {
            return [shop]
        } else {
            return []
        }
    }
    
    var elementName: String {
        return "yml_catalog"
    }
    
    mutating func addChild(_ child: XMLElement) {
        if child.elementName == "shop", let shop = child as? YMLShop {
            self.shop = shop
        }
    }
}

extension YMLCatalog {
    init(attributes: [String : String]) {
        self.attributes = attributes
    }
}
