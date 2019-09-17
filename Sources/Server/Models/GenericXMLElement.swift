//
//  GenericXMLElement.swift
//
//  Created by Denis Bystruev on 14/09/2019.
//

struct GenericXMLElement: XMLElement {
    var attributes: [String: String]
    var characters = ""
    var children: [XMLElement]
    var elementName: String
    
    init(
        attributes: [String: String] = [:],
        characters: String = "",
        children: [XMLElement] = [],
        elementName: String
    ) {
        self.attributes = attributes
        self.characters = characters
        self.children = children
        self.elementName = elementName
    }
}
