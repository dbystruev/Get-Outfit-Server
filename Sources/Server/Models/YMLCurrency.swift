//
//  YMLCurrency.swift
//
//  Created by Denis Bystruev on 13/09/2019.
//
//  See https://yandex.ru/support/partnermarket/elements/currencies.html

struct YMLCurrency: Codable {
    var id: String?
    var rate: String?
}

// MARK: - XMLElement
extension YMLCurrency: XMLElement {
    var attributes: [String : String] {
        get {
            var attributes = [String: String]()
            attributes["id"] = id
            attributes["rate"] = rate
            return attributes
        }
        set {
            id = newValue["id"]
            rate = newValue["rate"]
        }
    }
    
    var elementName: String {
        return "currency"
    }
}

extension YMLCurrency {
    init(attributes: [String: String]) {
        self.attributes = attributes
    }
}
