//
//  YMLCategory.swift
//
//  Created by Denis Bystruev on 13/09/2019.
//
//  See https://yandex.ru/support/partnermarket/elements/categories.html

struct YMLCategory: Codable {
    var id: Int?
    var name: String?
    var parentId: Int?
}

// MARK: - XMLElement
extension YMLCategory: XMLElement {
    var attributes: [String : String] {
        get {
            var attributes = [String: String]()
            if let id = id { attributes["id"] = "\(id)" }
            if let parentId = parentId { attributes["parentId"] = "\(parentId)" }
            return attributes
        }
        set {
            if let id = newValue["id"] { self.id = Int(id) }
            if let parentId = newValue["parentId"] { self.parentId = Int(parentId) }
        }
    }
    
    var elementName: String {
        return "category"
    }
    
    mutating func foundCharacters(_ string: String) {
        name = (name ?? "") + string
    }
}

extension YMLCategory {
    init(attributes: [String : String]) {
        self.attributes = attributes
    }
}
