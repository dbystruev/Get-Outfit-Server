//
//  GenericXMLElement.swift
//
//  Created by Denis Bystruev on 14/09/2019.
//

struct GenericXMLElement: XMLElement {
    var attributes = [String: String]()
    var characters = ""
    var children: [XMLElement]
    var elementName: String
    
    init(attributes: [String: String] = [:], children: [XMLElement] = [], elementName: String) {
        self.attributes = attributes
        self.children = children
        self.elementName = elementName
    }
    
    mutating func addChild(_ child: XMLElement) {
        children.append(child)
    }
    
    mutating func foundCharacters(_ string: String) {
        characters += string
    }
}
