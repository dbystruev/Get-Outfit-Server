//
//  YMLParam.swift
//
//  Created by Denis Bystruev on 15/09/2019.
//
//  See https://yandex.ru/support/partnermarket/elements/param.html

struct YMLParam: Codable {
    var name: String?
    var unit: String?
    var value: String?
}

// MARK: - XMLElement
extension YMLParam: XMLElement {
    var attributes: [String : String] {
        get {
            var attributes = [String: String]()
            attributes["name"] = name
            attributes["unit"] = unit
            return attributes
        }
        set {
            name = newValue["name"]
            unit = newValue["unit"]
        }
    }
    
    var characters: String {
        get {
            return value ?? ""
        }
        set {
            value = newValue
        }
    }
    
    var elementName: String {
        return "param"
    }
}

extension YMLParam {
    init(attributes: [String : String]) {
        self.attributes = attributes
    }
}
