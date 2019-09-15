//
//  XMLElement.swift
//
//  Created by Denis Bystruev on 14/09/2019.
//

protocol XMLElement {
    var attributes: [String: String] { get set }
    var characters: String { get set }
    var children: [XMLElement] { get }
    var elementName: String { get }
    
    mutating func addChild(_ child: XMLElement)
    mutating func foundCharacters(_ string: String)
}

extension XMLElement {
    static func createElement(withName name: String, attributes: [String: String] = [:]) -> XMLElement {
        switch name {
        case "category":
            return YMLCategory(attributes: attributes)
        case "currency":
            return YMLCurrency(attributes: attributes)
        case "offer":
            return YMLOffer(attributes: attributes)
        case "param":
            return YMLParam(attributes: attributes)
        case "shop":
            return YMLShop()
        case "yml_catalog":
            return YMLCatalog(attributes: attributes)
        default:
            return GenericXMLElement(attributes: attributes, elementName: name)
        }
    }
    
    var attributes: [String : String] {
        get { return [:] }
        set {}
    }
    
    var characters: String {
        get { return "" }
        set {}
    }
    
    var children: [XMLElement] { return [] }
    
    mutating func addChild(_ child: XMLElement) {}
    
    mutating func foundCharacters(_ string: String) {
        characters += string
    }
}
